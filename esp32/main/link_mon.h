/*
 * link_mon.h - downstream (STM32) link silence watchdog.
 */
#ifndef LINK_MON_H
#define LINK_MON_H

void link_mon_init(void);
void link_mon_mark_uart_rx(void);

#endif /* LINK_MON_H */
