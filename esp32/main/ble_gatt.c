/*
 * ble_gatt.c - NimBLE GATT server (protocol v1 transport, zero interpretation).
 * Based on the standard NimBLE GATT server pattern (ESP-IDF v5.x).
 */
#include "ble_gatt.h"

#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "host/ble_att.h"
#include "host/ble_gap.h"
#include "host/ble_hs.h"
#include "host/ble_uuid.h"
#include "nimble/nimble_port.h"
#include "nimble/nimble_port_freertos.h"
#include "services/gap/ble_svc_gap.h"
#include "services/gatt/ble_svc_gatt.h"
#include "store/config/ble_store_config.h"
#include "esp_log.h"

static const char *TAG = "ble_gatt";

/* this NimBLE drop defines ble_store_config_init() in
 * host/store/config/src/ble_store_config.c without a header declaration */
extern void ble_store_config_init(void);

/* ---- protocol v1 UUIDs (frozen 2026-11-14) ----
 * OTA (little-endian) byte order of the 128-bit UUIDs. */
static const ble_uuid128_t svc_uuid =
    BLE_UUID128_INIT(0x77, 0x87, 0x95, 0xD9, 0x60, 0xF5, 0x6C, 0x9D,
                     0xA4, 0x4B, 0xE8, 0xCA, 0x76, 0xC9, 0xB5, 0x48);

static const ble_uuid128_t chr_write_uuid =
    BLE_UUID128_INIT(0x77, 0x87, 0x95, 0xD9, 0x60, 0xF5, 0x6C, 0x9D,
                     0xA5, 0x4B, 0xE8, 0xCA, 0x76, 0xC9, 0xB5, 0x48);

static const ble_uuid128_t chr_notify_uuid =
    BLE_UUID128_INIT(0x77, 0x87, 0x95, 0xD9, 0x60, 0xF5, 0x6C, 0x9D,
                     0xA6, 0x4B, 0xE8, 0xCA, 0x76, 0xC9, 0xB5, 0x48);

static uint16_t s_notify_val_handle;
static ble_gatt_write_cb_t s_write_cb;
static volatile bool s_subscribed;
static volatile uint16_t s_mtu = 517;

/* ---- GATT access callbacks ---- */

static int chr_write_cb(uint16_t conn_handle, uint16_t attr_handle,
                        struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    (void)conn_handle;
    (void)attr_handle;
    (void)arg;

    uint16_t om_len = OS_MBUF_PKTLEN(ctxt->om);
    if (om_len == 0 || s_write_cb == NULL) {
        return 0;
    }
    uint8_t buf[512];
    if (om_len > sizeof(buf)) {
        om_len = sizeof(buf);
    }
    int rc = ble_hs_mbuf_to_flat(ctxt->om, buf, sizeof(buf), &om_len);
    if (rc != 0) {
        ESP_LOGE(TAG, "mbuf_to_flat failed rc=%d", rc);
        return BLE_ATT_ERR_UNLIKELY;
    }
    s_write_cb(buf, om_len);
    return 0;
}

static int chr_notify_cb(uint16_t conn_handle, uint16_t attr_handle,
                         struct ble_gatt_access_ctxt *ctxt, void *arg)
{
    (void)conn_handle;
    (void)attr_handle;
    (void)arg;
    /* reads return empty payload (data flows via notify) */
    return 0;
}

static const struct ble_gatt_svc_def gatt_svcs[] = {
    {
        .type = BLE_GATT_SVC_TYPE_PRIMARY,
        .uuid = (const ble_uuid_t *)&svc_uuid,
        .characteristics = (struct ble_gatt_chr_def[]){
            {
                .uuid = (const ble_uuid_t *)&chr_write_uuid,
                .access_cb = chr_write_cb,
                .flags = BLE_GATT_CHR_F_WRITE | BLE_GATT_CHR_F_WRITE_NO_RSP,
            },
            {
                .uuid = (const ble_uuid_t *)&chr_notify_uuid,
                .access_cb = chr_notify_cb,
                .val_handle = &s_notify_val_handle,
                .flags = BLE_GATT_CHR_F_READ | BLE_GATT_CHR_F_NOTIFY,
            },
            {0},
        },
    },
    {0},
};

/* ---- GAP events ---- */

static void start_advertising(void);

static int gap_event_cb(struct ble_gap_event *event, void *arg)
{
    (void)arg;
    switch (event->type) {
    case BLE_GAP_EVENT_CONNECT:
        if (event->connect.status == 0) {
            ESP_LOGI(TAG, "phone connected, conn=%d", event->connect.conn_handle);
            /* ask for a large MTU so one protocol frame fits one notification */
            ble_att_set_preferred_mtu(517);
        } else {
            ESP_LOGW(TAG, "connect failed rc=%d, re-adv", event->connect.status);
            start_advertising();
        }
        return 0;

    case BLE_GAP_EVENT_DISCONNECT:
        ESP_LOGI(TAG, "disconnected rc=0x%02x (0x13=phone-side, 0x08=timeout, 0x22=ATT)",
                 event->disconnect.reason);
        s_subscribed = false;
        start_advertising();
        return 0;

    case BLE_GAP_EVENT_SUBSCRIBE:
        if (event->subscribe.attr_handle == s_notify_val_handle) {
            s_subscribed = (event->subscribe.cur_notify != 0);
            ESP_LOGI(TAG, "notify sub=%d", s_subscribed);
        }
        return 0;

    case BLE_GAP_EVENT_MTU:
        s_mtu = event->mtu.value;
        ESP_LOGI(TAG, "mtu=%d", s_mtu);
        return 0;

    default:
        return 0;
    }
}

static void start_advertising(void)
{
    struct ble_gap_adv_params adv_params = {0};
    adv_params.conn_mode = BLE_GAP_CONN_MODE_UND;
    adv_params.disc_mode = BLE_GAP_DISC_MODE_GEN;
    /* 100~200 ms interval for fast discovery */
    adv_params.itvl_min = 160; /* units of 0.625 ms */
    adv_params.itvl_max = 320;

    /* adv packet (<=31B): flags + complete 128-bit service UUID = 21B */
    struct ble_hs_adv_fields fields = {0};
    fields.flags = BLE_HS_ADV_F_DISC_GEN | BLE_HS_ADV_F_BREDR_UNSUP;
    fields.uuids128 = &svc_uuid;
    fields.num_uuids128 = 1;
    fields.uuids128_is_complete = 1;
    int rc = ble_gap_adv_set_fields(&fields);
    if (rc != 0) {
        ESP_LOGE(TAG, "adv_set_fields rc=%d", rc);
        return;
    }

    /* scan response (<=31B): device name */
    const char *name = ble_svc_gap_device_name();
    struct ble_hs_adv_fields rsp = {0};
    rsp.name = (const uint8_t *)name;
    rsp.name_len = (uint8_t)strlen(name);
    rsp.name_is_complete = 1;
    rc = ble_gap_adv_rsp_set_fields(&rsp);
    if (rc != 0) {
        ESP_LOGE(TAG, "adv_rsp_set_fields rc=%d", rc);
        return;
    }

    rc = ble_gap_adv_start(BLE_OWN_ADDR_PUBLIC, NULL, BLE_HS_FOREVER,
                           &adv_params, gap_event_cb, NULL);
    if (rc != 0 && rc != BLE_HS_EALREADY) {
        ESP_LOGE(TAG, "adv_start rc=%d", rc);
    }
}

static void on_sync(void)
{
    int rc = ble_gatts_count_cfg(gatt_svcs);
    if (rc != 0) {
        ESP_LOGE(TAG, "gatts_count_cfg rc=%d", rc);
        return;
    }
    rc = ble_gatts_add_svcs(gatt_svcs);
    if (rc != 0) {
        ESP_LOGE(TAG, "gatts_add_svcs rc=%d", rc);
        return;
    }
    ble_svc_gap_device_name_set(CONFIG_C4F7N_ADV_NAME);
    ble_gatts_start();
    ble_att_set_preferred_mtu(517);
    ESP_LOGI(TAG, "stack synced, advertising as %s", CONFIG_C4F7N_ADV_NAME);
    start_advertising();
}

static void on_reset(int reason)
{
    ESP_LOGW(TAG, "host reset rc=%d", reason);
}

static void host_task(void *param)
{
    nimble_port_run(); /* returns on nimble_port_stop() */
    nimble_port_freertos_deinit();
}

/* ---- public API ---- */

void ble_gatt_init(ble_gatt_write_cb_t on_write)
{
    s_write_cb = on_write;
    ble_hs_cfg.sync_cb = on_sync;
    ble_hs_cfg.reset_cb = on_reset;
    nimble_port_init();

    ble_svc_gap_init();
    ble_svc_gatt_init();
    ble_store_config_init();   /* fixes "Failed to restore IRKs status=8" */
    /* gap device name buffer: services/gap default 32 bytes is enough */
    nimble_port_freertos_init(host_task);
}

size_t ble_gatt_send_to_ble(const uint8_t *data, size_t len)
{
    if (!s_subscribed || len == 0) {
        return 0;
    }
    size_t chunk = s_mtu - 3; /* ATT notify payload cap */
    if (chunk == 0 || chunk > 512) {
        chunk = 512;
    }
    size_t sent = 0;
    while (sent < len) {
        size_t n = len - sent;
        if (n > chunk) {
            n = chunk;
        }
        struct os_mbuf *om = ble_hs_mbuf_from_flat(data + sent, n);
        if (om == NULL) {
            ESP_LOGW(TAG, "mbuf alloc fail, dropping %u bytes", (unsigned)(len - sent));
            break;
        }
        int rc = ble_gatts_notify_custom(0, s_notify_val_handle, om);
        if (rc != 0) {
            ESP_LOGW(TAG, "notify rc=%d (unsubscribed?)", rc);
            break;
        }
        sent += n;
    }
    return sent;
}
