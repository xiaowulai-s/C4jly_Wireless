/*
 * uart_bridge.c - transparent UART <-> BLE forwarding.
 *
 * Phone -> device: bytes from ble_gatt write-char go straight to the UART.
 * Device -> phone: UART RX is re-assembled into complete protocol v1 frames
 * (A5 5A | LEN | ... ) so each BLE notification carries exactly one frame;
 * any non-conforming stream is flushed as-is after 30 ms idle (transparent
 * fallback), keeping the bridge zero-interpretation.
 */
#include "uart_bridge.h"

#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include "esp_timer.h"
#include "esp_log.h"

#include "ble_gatt.h"
#include "link_mon.h"

#define WL_UART ((uart_port_t)CONFIG_C4F7N_UART_NUM)

static const char *TAG = "uart_bridge";

#define RX_BUF_SIZE   2048
#define FRAME_MAX     240     /* protocol v1 max payload+cmd */
#define FRAME_BUF     (FRAME_MAX + 5)

static uint8_t s_frame[FRAME_BUF];
static size_t s_len;
static esp_timer_handle_t s_flush_timer;

static void flush_timer_cb(void *arg)
{
    if (s_len > 0) {
        ble_gatt_send_to_ble(s_frame, s_len);
        s_len = 0;
    }
}

static void start_flush_timer(void)
{
    esp_timer_stop(s_flush_timer);
    esp_timer_start_once(s_flush_timer, 30 * 1000); /* 30 ms */
}

/* try to emit exactly one complete frame per notification */
static void assemble_and_forward(const uint8_t *data, size_t len)
{
    while (len > 0) {
        /* resync: look for A5 5A header */
        if (s_len == 0) {
            size_t skip = 0;
            while (skip + 1 < len &&
                   !(data[skip] == 0xA5 && data[skip + 1] == 0x5A)) {
                skip++;
            }
            if (skip > 0) {
                /* garbage before header: forward it as-is (transparent) */
                ble_gatt_send_to_ble(data, skip);
                data += skip;
                len -= skip;
                if (skip + 1 >= len) {
                    /* header may straddle: keep last byte if it is 0xA5 */
                    if (len == 1 && data[0] == 0xA5) {
                        s_frame[s_len++] = data[0];
                        len = 0;
                    } else {
                        len = 0;
                    }
                    break;
                }
            }
        }

        size_t take = len;
        size_t space = FRAME_BUF - s_len;
        if (take > space) {
            take = space;
        }
        memcpy(s_frame + s_len, data, take);
        s_len += take;
        data += take;
        len -= take;

        /* complete frame? A5 5A LEN (LEN = cmd+payload, total = LEN+5) */
        if (s_len >= 3 && s_len >= (size_t)(s_frame[2] + 5)) {
            size_t total = (size_t)(s_frame[2] + 5);
            ble_gatt_send_to_ble(s_frame, total);
            if (s_len > total) {
                memmove(s_frame, s_frame + total, s_len - total);
            }
            s_len -= total;
        } else {
            start_flush_timer(); /* partial frame: flush on idle */
        }
    }
}

static void uart_event_task(void *param)
{
    (void)param;
    static QueueHandle_t s_evt_queue;
    uint8_t buf[512];
    uart_event_t ev;
    /* install with our own event queue */
    uart_driver_install(CONFIG_C4F7N_UART_NUM, RX_BUF_SIZE, 0,
                        20, &s_evt_queue, 0);
    for (;;) {
        if (xQueueReceive(s_evt_queue, &ev, portMAX_DELAY) != pdTRUE) {
            continue;
        }
        switch (ev.type) {
        case UART_DATA: {
            int n = uart_read_bytes(WL_UART, buf,
                                    sizeof(buf), pdMS_TO_TICKS(20));
            if (n > 0) {
                link_mon_mark_uart_rx();
                assemble_and_forward(buf, (size_t)n);
            }
            break;
        }
        case UART_FIFO_OVF:
        case UART_BUFFER_FULL:
            ESP_LOGW(TAG, "uart overflow, flushing rx");
            uart_flush_input(WL_UART);
            s_len = 0;
            break;
        default:
            break;
        }
    }
}

void uart_bridge_write(const uint8_t *data, size_t len)
{
    uart_write_bytes(WL_UART, data, len);
}

void uart_bridge_init(void)
{
    const uart_config_t cfg = {
        .baud_rate = CONFIG_C4F7N_UART_BAUD,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    ESP_ERROR_CHECK(uart_param_config(CONFIG_C4F7N_UART_NUM, &cfg));
    ESP_ERROR_CHECK(uart_set_pin(CONFIG_C4F7N_UART_NUM,
                                 CONFIG_C4F7N_UART_TX_PIN,
                                 CONFIG_C4F7N_UART_RX_PIN,
                                 -1, -1));

    const esp_timer_create_args_t targs = {
        .callback = flush_timer_cb,
        .name = "uart_flush",
    };
    ESP_ERROR_CHECK(esp_timer_create(&targs, &s_flush_timer));

    xTaskCreate(uart_event_task, "uart_evt", 4096, NULL, 10, NULL);
    ESP_LOGI(TAG, "uart%d tx=%d rx=%d @%d", CONFIG_C4F7N_UART_NUM,
             CONFIG_C4F7N_UART_TX_PIN, CONFIG_C4F7N_UART_RX_PIN,
             CONFIG_C4F7N_UART_BAUD);
}
