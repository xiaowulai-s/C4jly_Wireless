/*
 * wireless.h - Protocol v1 transport for the wireless edition (ESP32 on USART2).
 *
 * Frame: A5 5A | LEN | CMD | PAYLOAD | CRC16-MODBUS (spec: docs/协议v1.md)
 * STM32 hosts ALL business logic; the ESP32 is a dumb BLE<->UART bridge.
 *
 * Integration (patched into Core/Src/main.c):
 *   Wireless_Init()  after MX_USART3_UART_Init()
 *   Wireless_Poll()  inside the main while(1) loop (frame rx + 1 Hz report)
 *   wl_*() hooks     defined in main.c (they touch main.c statics)
 */
#ifndef WIRELESS_H
#define WIRELESS_H

#include <stdint.h>

/* --- hooks implemented in Core/Src/main.c (access statics there) --- */
uint16_t wl_get_thr(void);
void     wl_set_thr(uint16_t v);            /* commit thr + screen sync */
uint8_t  wl_get_state(void);                /* bit0 pump bit1 alarm bit2 mute */
void     wl_set_mute(uint8_t m);
uint8_t  wl_get_mute(void);
float    wl_get_ppm(void);
float    wl_get_peak(void);
void     wl_req_zero_cal(void);             /* g_cal_req = CAL_REQ_ZERO */
void     wl_req_span_cal(void);             /* g_cal_req = CAL_REQ_SPAN */
uint8_t  wl_cal_busy(void);                 /* nonzero while cal machine runs */
void     wl_set_man(int32_t b, int32_t k);  /* write man + save + reapply */
void     wl_factory_params(void);           /* param_factory + reapply */
uint8_t  wl_get_bat(void);                  /* battery display percent */
uint32_t wl_get_uptime_s(void);

/* --- module API --- */
void Wireless_Init(void);   /* USART2 + DMA rx + first report timer */
void Wireless_Poll(void);   /* call every main-loop pass */

#endif /* WIRELESS_H */
