/*
 * sensor.h - C4F7N 便携式检漏仪传感器驱动 (GC5G1 NDIR, 数字 UART 主动上报)
 *
 * 传感器   : GC5G1 全量程二氧化碳(C4F7N) 模块, NDIR 测量原理
 * 输出     : 数字 UART (TTL) 主动上报浓度帧
 * 接法     : 传感器 TX 接 STM32 PC11 (USART4_RX)
 *           传感器 RX 接 STM32 PC10 (USART4_TX)
 *           传感器 GND 接 STM32 GND (共地)
 *           传感器 VCC 接 12/24VDC 电源 (预留扩展)
 *
 * 通讯     : 9600 8N1, 主动上报 (无查询), 帧格式见 SENSOR_* 宏
 *
 * 注意     : 传感器需预热 >=2min; 存放(<=3个月)后再标定
 *            帧格式细节以厂家资料为准, 可修改
 */
#ifndef SENSOR_H
#define SENSOR_H


#include <stdint.h>

/* ---------- 用户可调参数 (帧格式, 以厂家资料为准) ---------- */
#define SENSOR_FS_PPM        1500.0f /* 传感器满量程 ppm (显示上限) */
#define SENSOR_SPAN_PPM      1000.0f /* 量程标定给定浓度 ppm (暴露给定ppm气体时做量程标定) */

/* 量程标定斜率钳位范围 (ppm_out = raw*cal_k/1000 + cal_b) */
#define SENSOR_CAL_K_MIN     100
#define SENSOR_CAL_K_MAX     10000

/* 传感器上报帧: 帧头(两个字节) + 浓度(小数, 2 字节) + 校验(可选)
 * 当前为占位定义, 待传感器协议确认后再完善 */
#define SENSOR_LINE_MAX      64
#define SENSOR_INIT_MS       5000u /* min power-on init window (covers startup saturation frame) */
#define SENSOR_FRM_MAXLEN    16      /* 单帧最大长度 */
#define SENSOR_FRM_HEAD0     0xAA    /* 帧头 0 */
#define SENSOR_FRM_HEAD1     0x55    /* 帧头 1 */
#define SENSOR_PPM_OFFSET    2       /* 浓度数据偏移(帧头后) */
#define SENSOR_PPM_BYTES     2       /* 浓度数据字节数(LSB) */

/* ---------- 接口（函数声明, 供上层调用） ---------- */
/* UART4 初始化 (9600 8N1) + 使能接收中断; 在 main 中优先调用 */
void    sensor_init(void);

/* 预热中? 1=仍在预热(上电到收到首行有效读数) */
int     sensor_warmup(void);

/* 取得最新一帧经校准的浓度 raw(mcu 用 k/b 做线性校准) (0~1000 ppm) */
float   sensor_read_ppm(void);

/* 取得最新一帧原始浓度 (未做标定校准, 供零点/量程标定读取原始量) */
float   sensor_read_raw(void);

/* 读取原始电压: 数字传感器无此功能, 为模拟接口保留, 未接回读数据返 0 */
float   sensor_read_voltage(void);

/*
 * 标定接口: 传感器原始值经 k/b 线性校准出 ppm (见 sensor_read_ppm)。
 * 供上位/便携标定设置; 若要读原始值再换算可在上层扩展。
 */
void    sensor_set_cal(int32_t k, int32_t b);
void    sensor_get_cal(int32_t *k, int32_t *b);

/* 数据可用标志: 有更新返回 1, 同时清除标志 (供上层轮询判断) */
int     sensor_has_new(void);

/* 探头在线判断: 最后一次有效帧距今未超时 => 1 (在线), 否则 0 (未接入) */
int     sensor_online(void);

/* ---- [v62] 厂商下行指令(10-12 用户提供字节, 已确认) ----
 * 零点校准: 必须在无被测气体时下发, 否则读数异常。
 * 15ppm 下限: 两条指令须【依次】下发, 下发后传感器侧把 0~15ppm 截零。
 * ★ 仅上行用 \\ 分割便于阅读, 数组本身不含分隔符。 */
#define SENSOR_CMD_ZERO_HW_LEN   6
#define SENSOR_CMD_LO15_LEN    11

/* ★ [v62] 数组【定义在 sensor.c】, 这里只声明 extern:
 *   sensor.h 被 selftest.c / main.c / stm32f1xx_it.c 共 4 个 TU 包含,
 *   若写成 static const 定义, 每个 TU 会各生成一份副本(白占 112B flash)。 */
extern const uint8_t SENSOR_CMD_ZERO_HW[SENSOR_CMD_ZERO_HW_LEN];
extern const uint8_t SENSOR_CMD_LO15_A[SENSOR_CMD_LO15_LEN];
extern const uint8_t SENSOR_CMD_LO15_B[SENSOR_CMD_LO15_LEN];

/* 下发一帧厂商指令(阻塞); len 用 sizeof(数组) 传入 */
void sensor_send_cmd(const uint8_t *buf, uint8_t len);

/* ---- [v62] 厂商下行指令(10-12 用户提供字节, 已确认) ----
 * 零点校准: 必须在无被测气体时下发, 否则读数异常。
 * 15ppm 下限: 两条指令须【依次】下发, 下发后传感器侧把 0~15ppm 截零。
 * ★ 仅上行用 \\ 分割便于阅读, 数组本身不含分隔符。 */
#define SENSOR_CMD_ZERO_HW_LEN   6
#define SENSOR_CMD_LO15_LEN    11

/* ★ [v62] 数组【定义在 sensor.c】, 这里只声明 extern:
 *   sensor.h 被 selftest.c / main.c / stm32f1xx_it.c 共 4 个 TU 包含,
 *   若写成 static const 定义, 每个 TU 会各生成一份副本(白占 112B flash)。 */
extern const uint8_t SENSOR_CMD_ZERO_HW[SENSOR_CMD_ZERO_HW_LEN];
extern const uint8_t SENSOR_CMD_LO15_A[SENSOR_CMD_LO15_LEN];
extern const uint8_t SENSOR_CMD_LO15_B[SENSOR_CMD_LO15_LEN];

/* 下发一帧厂商指令(阻塞); len 用 sizeof(数组) 传入 */
void sensor_send_cmd(const uint8_t *buf, uint8_t len);

/* UART4 中断处理函数 (由 stm32f1xx_it.c 的 UART4_IRQHandler 调用) */
void    sensor_uart4_irq_handler(void);

#endif /* SENSOR_H */