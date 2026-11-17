/*
 * uart_bridge.h - downstream UART (to STM32 USART1) with frame-aware forwarding.
 */
#ifndef UART_BRIDGE_H
#define UART_BRIDGE_H

#include <stdint.h>
#include <stddef.h>

typedef void (*uart_rx_cb_t)(const uint8_t *data, size_t len);

void uart_bridge_init(void);

/* write raw bytes out of the downstream UART (phone -> device direction) */
void uart_bridge_write(const uint8_t *data, size_t len);

#endif /* UART_BRIDGE_H */
