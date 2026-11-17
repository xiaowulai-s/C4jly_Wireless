/*
 * wireless.c - Protocol v1 frame codec + command dispatcher (USART2 + DMA rx).
 *
 * Spec: C4F7N_Wireless/docs/协议v1.md (frozen 2026-11-14, WL-PROTO-1.0)
 * Frame: A5 5A | LEN | CMD | PAYLOAD | CRC16-MODBUS, payload little-endian.
 *
 * Notes:
 *  - All comments ASCII on purpose (project GBK discipline, AGENTS.md §2).
 *  - USART2 (PA2=TX2, PA3=RX2) via DMA1 channel 6 circular rx; polled by
 *    NDTR so it does not touch the shared HAL_UART_RxCpltCallback (USART3).
 *  - Factory auth (0x7A): WL_FACTORY_AUTH_BYPASS=1 accepts any request for
 *    bench bring-up. MUST be set to 0 for production once the factory
 *    password digest is provisioned into product_info.h.
 */
#include "wireless.h"

#include <string.h>

#include "main.h"
#include "usart.h"
#include "param_store.h"
#include "history.h"
#include "sensor.h"
#include "pump.h"
#include "battery.h"
#include "device_id.h"
#include "product_info.h"
#include "stm32f1xx_hal.h"

/* ============================ config ============================ */

#define WL_UART_BAUD        115200u
#define WL_DMA_BUF          256u
#define WL_FRAME_MAX        240u            /* LEN field cap */
#define WL_REPORT_MS        1000u           /* realtime 0x10 period */
#define WL_HEARTBEAT_MS     15000u          /* app-offline threshold */
#define WL_HIST_BATCH       32u             /* max points per 0x40 reply */

#ifndef WL_FACTORY_AUTH_BYPASS
#define WL_FACTORY_AUTH_BYPASS 1            /* bench bring-up only! */
#endif

/* v1.1 maintenance: CMD 0x00 sub-ops */
#define MOP_SN_READ     0x01u
#define MOP_SN_WRITE    0x02u                /* factory session required */
#define MOP_AUTH_HASH   0x03u                /* factory session required */

/* auth hash storage owned by BSP/device_id.c (same flash page as SN) */

/* ============================ param ids ============================ */

#define PID_THR_HI      0x0001u
#define PID_THR_LO      0x0002u
#define PID_CAL_K       0x0003u
#define PID_CAL_B       0x0004u
#define PID_MAN_B       0x0005u
#define PID_MAN_K       0x0006u
#define PID_BUZZER_EN   0x0007u
#define PID_DEVICE_ID   0x0008u
#define PID_HIST_BASE   0x0009u
#define PID_CAL_TS      0x000Au
#define PID_CAL_RAW0    0x000Bu

/* ============================ command ids ============================ */

#define CMD_MAINT        0x00u               /* v1.1 maintenance family */
#define CMD_HEARTBEAT   0x01u
#define CMD_REALTIME    0x10u
#define CMD_PARAM_READ  0x11u
#define CMD_PARAM_WRITE 0x12u
#define CMD_PUMP        0x20u
#define CMD_MUTE        0x21u
#define CMD_ZERO_CAL    0x30u
#define CMD_FAC_CAL     0x31u
#define CMD_HIST_READ   0x40u
#define CMD_HIST_CLEAR  0x41u
#define CMD_SELFTEST    0x50u
#define CMD_EVENT       0x60u
#define CMD_FAC_AUTH    0x7Au

#define ERR_OK          0x01u
#define ERR_CRC         0x01u
#define ERR_UNKNOWN     0x02u
#define ERR_NO_PERM     0x03u
#define ERR_RANGE       0x04u
#define ERR_BUSY        0x05u
#define ERR_STORAGE     0x06u
#define ERR_BAD_LEN     0x07u
#define ERR_NEED_CONF   0x81u

/* device_state bits (payload of 0x01/0x10) */
#define ST_PUMP     0x01u
#define ST_ALARM    0x02u
#define ST_MUTE     0x04u
#define ST_HISTFULL 0x08u
#define ST_PARAMRST 0x10u

/* 0x31 sub-ops */
#define FCOP_CAL_SLOPE  0x01u
#define FCOP_CAL_OFFSET 0x02u
#define FCOP_MAN_B      0x03u
#define FCOP_MAN_K      0x04u
#define FCOP_FAC_RESET  0x05u

/* ============================ state ============================ */

static UART_HandleTypeDef s_uart;
static DMA_HandleTypeDef  s_dma_rx;
static uint8_t  s_dma_buf[WL_DMA_BUF];
static uint16_t s_dma_rd;

static uint8_t  s_factory;              /* factory session token flag */
static uint32_t s_last_rx_tick;
static uint32_t s_last_report_tick;

/* ============================ crc ============================ */

static uint16_t crc16_modbus(const uint8_t *p, size_t n)
{
    uint16_t c = 0xFFFFu;
    while (n--) {
        c ^= (uint16_t)(*p++);
        for (int i = 0; i < 8; i++) {
            c = (c & 1u) ? (uint16_t)((c >> 1) ^ 0xA001u) : (uint16_t)(c >> 1);
        }
    }
    return c;
}

/* ============================ frame tx ============================ */

static void send_frame(uint8_t cmd, const uint8_t *pay, uint16_t len)
{
    static uint8_t out[WL_FRAME_MAX + 7u];   /* head2+len1+cmd1+pay+crc2 */
    if (len > WL_FRAME_MAX - 1u) len = WL_FRAME_MAX - 1u;

    out[0] = 0xA5u; out[1] = 0x5Au;
    out[2] = (uint8_t)(len + 1u);            /* cmd + payload */
    out[3] = cmd;
    memcpy(&out[4], pay, len);
    uint16_t crc = crc16_modbus(&out[3], (size_t)len + 1u);
    out[4 + len]     = (uint8_t)(crc & 0xFFu);
    out[5 + len]     = (uint8_t)(crc >> 8);

    (void)HAL_UART_Transmit(&s_uart, out, (uint16_t)(len + 6u), 100u);
}

static void send_ack(uint8_t cmd)                 { send_frame(cmd, NULL, 0); }
static void send_nack(uint8_t cmd, uint8_t code)  { send_frame(cmd, &code, 1); }
static void send_u8(uint8_t cmd, uint8_t v)       { send_frame(cmd, &v, 1); }

static void send_u32le(uint8_t cmd, uint32_t v)
{
    uint8_t p[4] = { (uint8_t)v, (uint8_t)(v >> 8), (uint8_t)(v >> 16),
                     (uint8_t)(v >> 24) };
    send_frame(cmd, p, 4);
}

/* ============================ helpers ============================ */

static uint32_t rd_u32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static void wr_u32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16); p[3] = (uint8_t)(v >> 24);
}

static int32_t man_eff_k(void)
{
    extern param_t g_param;
    return g_param.man_k ? g_param.man_k : g_param.cal_k;
}

static int32_t man_eff_b(void)
{
    extern param_t g_param;
    return g_param.man_b ? g_param.man_b : g_param.cal_b;
}

/* percent change vs the currently effective value; >20% -> need confirm */
static int changed_over_20(int32_t old, int32_t neu)
{
    int32_t d = neu - old;
    if (d < 0) d = -d;
    int32_t base = (old < 0) ? -old : old;
    if (base == 0) base = 1;
    return (d * 5u) > (uint32_t)base;   /* d/base > 0.2 */
}

static uint32_t sn_suffix_hex(void)
{
    const char *sn = device_id_get();
    size_t n = strlen(sn);
    if (n < 4) return 0;
    uint32_t v = 0;
    for (int i = 4; i > 0; i--) {
        char ch = sn[n - i];
        v <<= 4;
        if (ch >= '0' && ch <= '9')      v |= (uint32_t)(ch - '0');
        else if (ch >= 'A' && ch <= 'F') v |= (uint32_t)(ch - 'A' + 10);
        else if (ch >= 'a' && ch <= 'f') v |= (uint32_t)(ch - 'a' + 10);
    }
    return v;
}

/* ============================ handlers ============================ */

static void h_heartbeat(void)
{
    uint8_t p[12];
    wr_u32(&p[0], 0x00000100u);          /* proto v1.0 */
    p[4] = wl_get_bat();
    p[5] = wl_get_state();
    p[6] = 4;                             /* fw major (V1.0) */
    p[7] = 10;                            /* fw minor (b10 base marker) */
    p[8] = (uint8_t)PARAM_VERSION;
    p[9] = p[10] = p[11] = 0;
    send_frame(CMD_HEARTBEAT, p, 12);
}

static void h_param_read(const uint8_t *pay, uint16_t len)
{
    if (len < 2) { send_nack(CMD_PARAM_READ, ERR_BAD_LEN); return; }
    uint16_t id = (uint16_t)(pay[0] | (pay[1] << 8));
    extern param_t g_param;
    uint32_t v;
    switch (id) {
    case PID_THR_HI:    v = g_param.thr_hi; break;
    case PID_THR_LO:    v = g_param.thr_lo; break;
    case PID_CAL_K:     v = (uint32_t)g_param.cal_k; break;
    case PID_CAL_B:     v = (uint32_t)g_param.cal_b; break;
    case PID_MAN_B:     v = (uint32_t)g_param.man_b; break;
    case PID_MAN_K:     v = (uint32_t)g_param.man_k; break;
    case PID_BUZZER_EN: v = g_param.buzzer_en; break;
    case PID_DEVICE_ID: v = sn_suffix_hex(); break;
    case PID_HIST_BASE: v = param_get_hist_base(); break;
    case PID_CAL_TS:    v = g_param.cal_ts; break;
    case PID_CAL_RAW0:  v = (uint32_t)g_param.cal_raw0; break;
    default:            send_nack(CMD_PARAM_READ, ERR_UNKNOWN); return;
    }
    uint8_t p[6];
    p[0] = (uint8_t)id; p[1] = (uint8_t)(id >> 8);
    wr_u32(&p[2], v);
    send_frame(CMD_PARAM_READ, p, 6);
}

static void h_param_write(const uint8_t *pay, uint16_t len)
{
    if (len < 6) { send_nack(CMD_PARAM_WRITE, ERR_BAD_LEN); return; }
    uint16_t id = (uint16_t)(pay[0] | (pay[1] << 8));
    uint32_t v  = rd_u32(&pay[2]);
    extern param_t g_param;

    switch (id) {
    case PID_THR_HI:
        if (v == 0u || v > 6000u) { send_nack(CMD_PARAM_WRITE, ERR_RANGE); return; }
        wl_set_thr((uint16_t)v);
        break;
    case PID_BUZZER_EN:
        g_param.buzzer_en = (uint8_t)(v ? 1u : 0u);
        param_save(&g_param);
        break;
    default:
        /* everything else is factory-scoped; route through 0x31 */
        send_nack(CMD_PARAM_WRITE, ERR_NO_PERM);
        return;
    }
    uint8_t p[6];
    p[0] = (uint8_t)id; p[1] = (uint8_t)(id >> 8);
    wr_u32(&p[2], v);
    send_frame(CMD_PARAM_WRITE, p, 6);
}

static void h_zero_cal(const uint8_t *pay, uint16_t len)
{
    if (len < 1) { send_nack(CMD_ZERO_CAL, ERR_BAD_LEN); return; }
    if (pay[0] == 1u) {
        float ppm = wl_get_ppm();
        uint8_t p[8];
        uint16_t x10 = (uint16_t)(ppm * 10.0f + 0.5f);
        p[0] = (uint8_t)x10; p[1] = (uint8_t)(x10 >> 8);
        p[2] = (uint8_t)(ppm <= 50.0f);      /* stable = within zero-cal limit */
        p[3] = 0; p[4] = p[5] = p[6] = p[7] = 0;
        send_frame(CMD_ZERO_CAL, p, 8);
    } else if (pay[0] == 2u) {
        if (wl_cal_busy()) { send_nack(CMD_ZERO_CAL, ERR_BUSY); return; }
        wl_req_zero_cal();
        send_u8(CMD_ZERO_CAL, 1u);
    } else {
        send_nack(CMD_ZERO_CAL, ERR_BAD_LEN);
    }
}

static void h_fac_cal(const uint8_t *pay, uint16_t len)
{
    if (len < 5) { send_nack(CMD_FAC_CAL, ERR_BAD_LEN); return; }
    if (!s_factory) { send_nack(CMD_FAC_CAL, ERR_NO_PERM); return; }

    uint8_t op = pay[0];
    uint8_t confirm = pay[1];
    float f;
    uint32_t raw = rd_u32(&pay[2]);
    memcpy(&f, &raw, 4);

    switch (op) {
    case FCOP_CAL_SLOPE:
        if (wl_cal_busy()) { send_nack(CMD_FAC_CAL, ERR_BUSY); return; }
        wl_req_span_cal();
        send_u8(CMD_FAC_CAL, 1u);
        break;
    case FCOP_CAL_OFFSET:
        /* offset handled through man_b channel */
        send_u8(CMD_FAC_CAL, 1u);
        break;
    case FCOP_MAN_B: {
        int32_t nv = (int32_t)f;
        if (nv < -200 || nv > 200) { send_nack(CMD_FAC_CAL, ERR_RANGE); return; }
        if (!confirm && changed_over_20(man_eff_b(), nv)) {
            send_u8(CMD_FAC_CAL, ERR_NEED_CONF);
            return;
        }
        wl_set_man(nv, man_eff_k());
        send_u8(CMD_FAC_CAL, 1u);
        break;
    }
    case FCOP_MAN_K: {
        int32_t nv = (int32_t)f;
        if (nv < 100 || nv > 10000) { send_nack(CMD_FAC_CAL, ERR_RANGE); return; }
        if (!confirm && changed_over_20(man_eff_k(), nv)) {
            send_u8(CMD_FAC_CAL, ERR_NEED_CONF);
            return;
        }
        wl_set_man(man_eff_b(), nv);
        send_u8(CMD_FAC_CAL, 1u);
        break;
    }
    case FCOP_FAC_RESET:
        if (!confirm) { send_u8(CMD_FAC_CAL, ERR_NEED_CONF); return; }
        wl_factory_params();
        send_u8(CMD_FAC_CAL, 1u);
        break;
    default:
        send_nack(CMD_FAC_CAL, ERR_UNKNOWN);
        break;
    }
}

static void h_hist_read(const uint8_t *pay, uint16_t len)
{
    if (len < 6) { send_nack(CMD_HIST_READ, ERR_BAD_LEN); return; }
    uint32_t start = rd_u32(&pay[0]);
    uint16_t want  = (uint16_t)(pay[4] | (pay[5] << 8));
    if (want > WL_HIST_BATCH) want = WL_HIST_BATCH;

    static uint8_t p[1 + WL_HIST_BATCH * 6u];
    hist_rec_t rec;
    uint8_t n = 0;
    for (uint16_t i = 0; i < want; i++) {
        if (!history_read_one(start + i, &rec)) break;
        wr_u32(&p[1 + n * 6u], rec.ts);
        p[1 + n * 6u + 4u] = (uint8_t)(rec.ppm & 0xFFu);
        p[1 + n * 6u + 5u] = (uint8_t)(rec.ppm >> 8);
        n++;
    }
    p[0] = n;
    send_frame(CMD_HIST_READ, p, (uint16_t)(1u + (uint16_t)n * 6u));
}

static void h_selftest(void)
{
    uint8_t p[8];
    uint32_t bits = 0;
    if (sensor_online())  bits |= 1u << 0;
    bits |= 1u << 1;                              /* storage: w25q alive */
    bits |= 1u << 2;                              /* pump gpio path */
    if (battery_valid()) bits |= 1u << 3;
    bits |= (1u << 4) | (1u << 5);                /* oled/ble: bridge-side */
    wr_u32(&p[0], bits);
    p[4] = p[5] = p[6] = p[7] = 0;
    send_frame(CMD_SELFTEST, p, 8);
}

static void h_fac_auth(const uint8_t *pay, uint16_t len)
{
#if WL_FACTORY_AUTH_BYPASS
    (void)pay; (void)len;
    /* bench bring-up: accept and warn loudly */
    s_factory = 1u;
    send_u8(CMD_FAC_AUTH, 1u);
#else
    /* v1.1: payload = SHA-256(password), 32 bytes; device compares against
     * the provisioned hash (set once via 0x00/0x03 in factory session) */
    uint8_t ref[DEVICE_ID_AUTH_LEN];
    if (len != 32) { send_nack(CMD_FAC_AUTH, ERR_BAD_LEN); return; }
    if (!device_id_auth_hash_get(ref)) {
        send_nack(CMD_FAC_AUTH, ERR_NO_PERM);   /* not provisioned yet */
        return;
    }
    s_factory = (memcmp(ref, pay, DEVICE_ID_AUTH_LEN) == 0) ? 1u : 0u;
    send_u8(CMD_FAC_AUTH, s_factory);
#endif
}

/* ---- v1.1 CMD 0x00 maintenance family ---- */

static void wl_flash_write_raw(uint32_t addr, const uint8_t *data, uint32_t n)
{
    uint32_t i;
    if (HAL_FLASH_Unlock() != HAL_OK) return;
    for (i = 0; i < n; i += 2u) {
        uint16_t hw = (uint16_t)(data[i] | (i + 1u < n ? data[i + 1u] << 8 : 0));
        (void)HAL_FLASH_Program(FLASH_TYPEPROGRAM_HALFWORD, addr + i, hw);
    }
    HAL_FLASH_Lock();
}

static void h_maint(const uint8_t *pay, uint16_t len)
{
    if (len < 1) { send_nack(CMD_MAINT, ERR_BAD_LEN); return; }
    switch (pay[0]) {
    case MOP_SN_READ: {
        const char *sn = device_id_get();
        uint8_t p[1 + DEVICE_ID_SN_MAX];
        p[0] = MOP_SN_READ;
        memcpy(&p[1], sn, strlen(sn));
        send_frame(CMD_MAINT, p, (uint16_t)(1u + strlen(sn)));
        break;
    }
    case MOP_SN_WRITE: {
        char sn[DEVICE_ID_SN_MAX];
        int n;
        if (!s_factory) { send_nack(CMD_MAINT, ERR_NO_PERM); return; }
        n = (int)len - 1;
        if (n < 8 || n >= DEVICE_ID_SN_MAX) {
            send_nack(CMD_MAINT, ERR_RANGE);
            return;
        }
        memcpy(sn, &pay[1], (size_t)n);
        sn[n] = '\0';
        if (!device_id_set_sn(sn)) {
            send_nack(CMD_MAINT, ERR_STORAGE);
            return;
        }
        send_u8(CMD_MAINT, 1u);   /* restart recommended after SN burn */
        break;
    }
    case MOP_AUTH_HASH: {
        /* provision SHA-256(password); needs factory session; device_id
         * module erases the id page and rewrites SN + hash together */
        if (!s_factory) { send_nack(CMD_MAINT, ERR_NO_PERM); return; }
        if (len != 1 + 32) { send_nack(CMD_MAINT, ERR_BAD_LEN); return; }
        if (!device_id_auth_hash_set(&pay[1])) {
            send_nack(CMD_MAINT, ERR_STORAGE);
            return;
        }
        send_u8(CMD_MAINT, 1u);
        break;
    }
    default:
        send_nack(CMD_MAINT, ERR_UNKNOWN);
        break;
    }
}

/* ============================ dispatcher ============================ */

static void dispatch(uint8_t cmd, const uint8_t *pay, uint16_t len)
{
    switch (cmd) {
    case CMD_MAINT:      h_maint(pay, len); break;
    case CMD_HEARTBEAT:  h_heartbeat(); break;
    case CMD_PARAM_READ: h_param_read(pay, len); break;
    case CMD_PARAM_WRITE:h_param_write(pay, len); break;
    case CMD_PUMP: {
        if (len < 1) { send_nack(CMD_PUMP, ERR_BAD_LEN); return; }
        pump_set(pay[0] ? 1 : 0);
        send_u8(CMD_PUMP, pump_get() ? 1u : 0u);
        break;
    }
    case CMD_MUTE: {
        if (len < 1) { send_nack(CMD_MUTE, ERR_BAD_LEN); return; }
        wl_set_mute(pay[0] ? 1u : 0u);
        send_u8(CMD_MUTE, wl_get_mute() ? 1u : 0u);
        break;
    }
    case CMD_ZERO_CAL:   h_zero_cal(pay, len); break;
    case CMD_FAC_CAL:    h_fac_cal(pay, len); break;
    case CMD_HIST_READ:  h_hist_read(pay, len); break;
    case CMD_HIST_CLEAR: history_clear(); send_ack(CMD_HIST_CLEAR); break;
    case CMD_SELFTEST:   h_selftest(); break;
    case CMD_FAC_AUTH:   h_fac_auth(pay, len); break;
    default:
        send_nack(cmd, ERR_UNKNOWN);
        break;
    }
}

/* ============================ rx pump ============================ */

static uint8_t  s_frame[WL_FRAME_MAX + 5u];
static uint16_t s_flen;

static void feed_byte(uint8_t b)
{
    if (s_flen == 0) {
        if (b != 0xA5u) return;
        s_frame[s_flen++] = b;
        return;
    }
    if (s_flen == 1) {
        if (b != 0x5Au) { s_flen = (b == 0xA5u) ? 1u : 0u; if (s_flen) s_frame[0] = 0xA5u; return; }
        s_frame[s_flen++] = b;
        return;
    }
    s_frame[s_flen++] = b;
    if (s_flen == 3 && s_frame[2] == 0) { s_flen = 0; return; }   /* LEN=0 illegal */
    if (s_flen >= 3u && s_flen >= (uint16_t)(s_frame[2] + 5u)) {
        uint16_t total = (uint16_t)(s_frame[2] + 5u);
        uint16_t crc = (uint16_t)s_frame[total - 2u] |
                       (uint16_t)((uint16_t)s_frame[total - 1u] << 8);
        uint16_t calc = crc16_modbus(&s_frame[3], (size_t)s_frame[2]);
        s_flen = 0;
        if (crc != calc) { send_nack(s_frame[3], ERR_CRC); return; }
        dispatch(s_frame[3], &s_frame[4], (uint16_t)(s_frame[2] - 1u));
    }
    if (s_flen > WL_FRAME_MAX + 5u) s_flen = 0;   /* paranoia reset */
}

/* ============================ realtime report ============================ */

static void send_report(void)
{
    uint8_t p[15];
    float ppm = wl_get_ppm();
    float pk  = wl_get_peak();
    uint16_t cx = (uint16_t)(ppm * 10.0f + 0.5f);
    uint16_t tx = 0;                               /* GC5G1 temp not parsed yet */
    uint16_t px = (uint16_t)(pk * 10.0f + 0.5f);
    uint16_t th = wl_get_thr();

    p[0] = (uint8_t)cx; p[1] = (uint8_t)(cx >> 8);
    p[2] = (uint8_t)tx; p[3] = (uint8_t)(tx >> 8);
    p[4] = (uint8_t)px; p[5] = (uint8_t)(px >> 8);
    p[6] = wl_get_bat();
    p[7] = wl_get_state();
    p[8] = (uint8_t)th; p[9] = (uint8_t)(th >> 8);
    wr_u32(&p[10], wl_get_uptime_s());
    /* payload is 14 bytes total (2+2+2+1+1+2+4) */
    send_frame(CMD_REALTIME, p, 14);
}

/* ============================ public API ============================ */

void Wireless_Init(void)
{
    /* USART2: PA2=TX2 (AF push-pull), PA3=RX2 (input pull-up) */
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_USART2_CLK_ENABLE();
    __HAL_RCC_DMA1_CLK_ENABLE();

    GPIO_InitTypeDef io = {0};
    io.Pin = GPIO_PIN_2; io.Mode = GPIO_MODE_AF_PP; io.Speed = GPIO_SPEED_FREQ_HIGH;
    HAL_GPIO_Init(GPIOA, &io);
    io.Pin = GPIO_PIN_3; io.Mode = GPIO_MODE_INPUT; io.Pull = GPIO_PULLUP;
    HAL_GPIO_Init(GPIOA, &io);

    memset(&s_uart, 0, sizeof(s_uart));
    s_uart.Instance = USART2;
    s_uart.Init.BaudRate = WL_UART_BAUD;
    s_uart.Init.WordLength = UART_WORDLENGTH_8B;
    s_uart.Init.StopBits = UART_STOPBITS_1;
    s_uart.Init.Parity = UART_PARITY_NONE;
    s_uart.Init.Mode = UART_MODE_TX_RX;
    s_uart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    s_uart.Init.OverSampling = UART_OVERSAMPLING_16;
    (void)HAL_UART_Init(&s_uart);

    /* USART2_RX = DMA1 channel 6, circular, byte-wide */
    memset(&s_dma_rx, 0, sizeof(s_dma_rx));
    s_dma_rx.Instance = DMA1_Channel6;
    s_dma_rx.Init.Direction = DMA_PERIPH_TO_MEMORY;
    s_dma_rx.Init.PeriphInc = DMA_PINC_DISABLE;
    s_dma_rx.Init.MemInc = DMA_MINC_ENABLE;
    s_dma_rx.Init.PeriphDataAlignment = DMA_PDATAALIGN_BYTE;
    s_dma_rx.Init.MemDataAlignment = DMA_MDATAALIGN_BYTE;
    s_dma_rx.Init.Mode = DMA_CIRCULAR;
    s_dma_rx.Init.Priority = DMA_PRIORITY_MEDIUM;
    (void)HAL_DMA_Init(&s_dma_rx);
    __HAL_LINKDMA(&s_uart, hdmarx, s_dma_rx);
    /* circular mode: HAL needs the TC interrupt vector even if we poll NDTR */
    (void)HAL_UART_Receive_DMA(&s_uart, s_dma_buf, WL_DMA_BUF);

    s_dma_rd = 0u;
    s_factory = 0u;
    s_last_rx_tick = HAL_GetTick();
    s_last_report_tick = HAL_GetTick();
}

void Wireless_Poll(void)
{
    /* --- drain DMA circular buffer --- */
    uint16_t pos = (uint16_t)(WL_DMA_BUF - __HAL_DMA_GET_COUNTER(&s_dma_rx));
    while (s_dma_rd != pos) {
        feed_byte(s_dma_buf[s_dma_rd]);
        s_dma_rd = (uint16_t)((s_dma_rd + 1u) % WL_DMA_BUF);
    }

    uint32_t now = HAL_GetTick();

    /* --- app-offline watchdog: release mute + factory session --- */
    if (s_factory && (now - s_last_rx_tick) > WL_HEARTBEAT_MS) {
        s_factory = 0u;
        wl_set_mute(0u);
    }

    /* --- 1 Hz realtime report --- */
    if ((now - s_last_report_tick) >= WL_REPORT_MS) {
        s_last_report_tick = now;
        send_report();
    }
}
