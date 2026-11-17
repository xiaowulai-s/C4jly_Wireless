**STM32F103RCT6 = LQFP64 封装**，256KB Flash / 48KB SRAM，属 **High-density（大容量）系列**——比常见的 C8T6 多了 **TIM8、SDIO、UART4/5、DAC**​ 等外设，51 个可用 IO。

下表按 datasheet 引脚定义整理（主功能 = 复位后默认，可重映射列需配置 AFIO）。

## 一、完整引脚复用表（LQFP64）

| 脚   | 引脚名             | 主功能（复位后）          | 默认复用                                             | 重映射                     |
| --- | --------------- | ----------------- | ------------------------------------------------ | ----------------------- |
| 1   | VBAT            | 后备电源              | RTC / 备份寄存器供电                                    | —                       |
| 2   | PC13-TAMPER-RTC | PC13              | TAMPER-RTC                                       | —                       |
| 3   | PC14-OSC32_IN   | PC14              | OSC32_IN（LSE）                                    | —                       |
| 4   | PC15-OSC32_OUT  | PC15              | OSC32_OUT（LSE）                                   | —                       |
| 5   | PD0-OSC_IN      | OSC_IN（HSE）       | FSMC_D2                                          | **CAN_RX**​             |
| 6   | PD1-OSC_OUT     | OSC_OUT（HSE）      | FSMC_D3                                          | **CAN_TX**​             |
| 7   | NRST            | 复位（低有效）           | —                                                | —                       |
| 8   | PC0             | PC0               | ADC123_IN10                                      | —                       |
| 9   | PC1             | PC1               | ADC123_IN11                                      | —                       |
| 10  | PC2             | PC2               | ADC123_IN12                                      | —                       |
| 11  | PC3             | PC3               | ADC123_IN13                                      | —                       |
| 12  | VSSA            | 模拟地               | —                                                | —                       |
| 13  | VDDA            | 模拟电源              | —                                                | —                       |
| 14  | PA0-WKUP        | PA0               | WKUP / USART2_CTS / ADC123_IN0 / TIM2_CH1_ETR    | TIM5_CH1 / TIM8_ETR     |
| 15  | PA1             | PA1               | USART2_RTS / ADC123_IN1 / TIM2_CH2               | TIM5_CH2                |
| 16  | PA2             | PA2               | USART2_TX / ADC123_IN2 / TIM2_CH3                | TIM5_CH3                |
| 17  | PA3             | PA3               | USART2_RX / ADC123_IN3 / TIM2_CH4                | TIM5_CH4                |
| 18  | VSS_4           | 数字地               | —                                                | —                       |
| 19  | VDD_4           | 数字电源              | —                                                | —                       |
| 20  | PA4             | PA4               | SPI1_NSS / USART2_CK / **DAC_OUT1**​ / ADC12_IN4 | —                       |
| 21  | PA5             | PA5               | SPI1_SCK / **DAC_OUT2**​ / ADC12_IN5             | —                       |
| 22  | PA6             | PA6               | SPI1_MISO / TIM8_BKIN / ADC12_IN6 / TIM3_CH1     | TIM1_BKIN               |
| 23  | PA7             | PA7               | SPI1_MOSI / TIM8_CH1N / ADC12_IN7 / TIM3_CH2     | TIM1_CH1N               |
| 24  | PC4             | PC4               | ADC12_IN14                                       | —                       |
| 25  | PC5             | PC5               | ADC12_IN15                                       | —                       |
| 26  | PB0             | PB0               | ADC12_IN8 / TIM3_CH3                             | TIM8_CH2N / TIM1_CH2N   |
| 27  | PB1             | PB1               | ADC12_IN9 / TIM3_CH4                             | TIM8_CH3N / TIM1_CH3N   |
| 28  | PB2             | PB2 / **BOOT1**​  | —                                                | —                       |
| 29  | PB10            | PB10              | I2C2_SCL / USART3_TX                             | TIM2_CH3                |
| 30  | PB11            | PB11              | I2C2_SDA / USART3_RX                             | TIM2_CH4                |
| 31  | VSS_1           | 数字地               | —                                                | —                       |
| 32  | VDD_1           | 数字电源              | —                                                | —                       |
| 33  | PB12            | PB12              | SPI2_NSS / I2S2_WS / I2C2_SMBA / USART3_CK       | TIM1_BKIN               |
| 34  | PB13            | PB13              | SPI2_SCK / I2S2_CK / USART3_CTS                  | TIM1_CH1N               |
| 35  | PB14            | PB14              | SPI2_MISO / TIM1_CH2N / USART3_RTS               | —                       |
| 36  | PB15            | PB15              | SPI2_MOSI / I2S2_SD                              | TIM1_CH3N               |
| 37  | PC6             | PC6               | I2S2_MCK / TIM8_CH1 / SDIO_D6                    | TIM3_CH1                |
| 38  | PC7             | PC7               | I2S3_MCK / TIM8_CH2 / SDIO_D7                    | TIM3_CH2                |
| 39  | PC8             | PC8               | TIM8_CH3 / SDIO_D0                               | TIM3_CH3                |
| 40  | PC9             | PC9               | TIM8_CH4 / SDIO_D1                               | TIM3_CH4                |
| 41  | PA8             | PA8               | USART1_CK / TIM1_CH1 / **MCO**​                  | —                       |
| 42  | PA9             | PA9               | **USART1_TX**​ / TIM1_CH2                        | —                       |
| 43  | PA10            | PA10              | **USART1_RX**​ / TIM1_CH3                        | —                       |
| 44  | PA11            | PA11              | USART1_CTS / **USBDM**​ / CAN_RX / TIM1_CH4      | —                       |
| 45  | PA12            | PA12              | USART1_RTS / **USBDP**​ / CAN_TX / TIM1_ETR      | —                       |
| 46  | PA13            | **JTMS / SWDIO**​ | 调试口                                              | PA13（释放后）               |
| 47  | VSS_2           | 数字地               | —                                                | —                       |
| 48  | VDD_2           | 数字电源              | —                                                | —                       |
| 49  | PA14            | **JTCK / SWCLK**​ | 调试口                                              | PA14（释放后）               |
| 50  | PA15            | JTDI              | SPI3_NSS / I2S3_WS                               | TIM2_CH1_ETR / SPI1_NSS |
| 51  | PC10            | PC10              | UART4_TX / SDIO_D2                               | USART3_TX               |
| 52  | PC11            | PC11              | UART4_RX / SDIO_D3                               | USART3_RX               |
| 53  | PC12            | PC12              | UART5_TX / SDIO_CK                               | USART3_CK               |
| 54  | PD2             | PD2               | TIM3_ETR / UART5_RX                              | SDIO_CMD                |
| 55  | PB3             | JTDO              | SPI3_SCK / I2S3_CK / TRACESWO                    | TIM2_CH2 / SPI1_SCK     |
| 56  | PB4             | NJTRST            | SPI3_MISO                                        | TIM3_CH1 / SPI1_MISO    |
| 57  | PB5             | PB5               | I2C1_SMBA / SPI3_MOSI / I2S3_SD                  | TIM3_CH2 / SPI1_MOSI    |
| 58  | PB6             | PB6               | **I2C1_SCL**​ / TIM4_CH1                         | USART1_TX               |
| 59  | PB7             | PB7               | **I2C1_SDA**​ / TIM4_CH2                         | USART1_RX               |
| 60  | BOOT0           | 启动模式选择            | —                                                | —                       |
| 61  | PB8             | PB8               | TIM4_CH3 / SDIO_D4                               | I2C1_SCL / CAN_RX       |
| 62  | PB9             | PB9               | TIM4_CH4 / SDIO_D5                               | I2C1_SDA / CAN_TX       |
| 63  | VSS_3           | 数字地               | —                                                | —                       |
| 64  | VDD_3           | 数字电源              | —                                                | —                       |

## 二、常用外设速查（直接用）

| 外设          | 默认引脚                             | 重映射引脚              |
| ----------- | -------------------------------- | ------------------ |
| **USART1**​ | PA9(TX) / PA10(RX)               | PB6(TX) / PB7(RX)  |
| **USART2**​ | PA2(TX) / PA3(RX)                | PD5/PD6（64 脚无此脚）   |
| **USART3**​ | PB10(TX) / PB11(RX)              | PC10 / PC11        |
| **UART4**​  | PC10 / PC11                      | —                  |
| **UART5**​  | PC12 / PD2                       | —                  |
| **SPI1**​   | PA5(SCK) PA6(MISO) PA7(MOSI)     | PB3 / PB4 / PB5    |
| **SPI2**​   | PB13(SCK) PB14(MISO) PB15(MOSI)  | —                  |
| **SPI3**​   | PB3(SCK) PB4(MISO) PB5(MOSI)     | —                  |
| **I2C1**​   | PB6(SCL) / PB7(SDA)              | PB8 / PB9          |
| **I2C2**​   | PB10(SCL) / PB11(SDA)            | —                  |
| **USB**​    | PA11(DM) / PA12(DP)              | 不可重映射              |
| **CAN**​    | PA11(RX) / PA12(TX)              | PB8/PB9 或 PD0/PD1  |
| **SDIO**​   | PC8~PC12 + PD2                   | —                  |
| **ADC**​    | PA0~PA7, PB0~PB1, PC0~PC5（16 通道） | —                  |
| **DAC**​    | PA4(OUT1) / PA5(OUT2)            | —                  |
| **TIM1**​   | PA8~PA11（+PB12~PB15 互补）          | —                  |
| **TIM2**​   | PA0~PA3                          | PA15/PB3/PB10/PB11 |
| **TIM3**​   | PA6/PA7/PB0/PB1                  | PC6~PC9            |
| **TIM4**​   | PB6~PB9                          | —                  |
| **TIM5**​   | PA0~PA3                          | —                  |
| **TIM8**​   | PC6~PC9（+PA7/PB0/PB1 互补）         | —                  |
| **SWD 调试**​ | PA13(SWDIO) / PA14(SWCLK)        | —                  |
