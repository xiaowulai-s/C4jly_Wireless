/*
 * hmi_get.h - `get` 应答帧解析(Screen -> MCU 数值回读)
 */
#ifndef HMI_GET_H
#define HMI_GET_H

#include <stdint.h>

void     hmi_get_reset(void);
int      hmi_get_feed(uint8_t b);      /* 喂字节; 1=帧完成, 0=非帧字节(可分发), -1=帧中间字节(须丢弃) */
uint32_t hmi_get_value(void);
uint8_t  hmi_get_is_string(void);

#endif /* HMI_GET_H */