/*
 * w25q16.c - W25Q64 SPI NOR Flash 驱动 (SPI1, CS=PA4)
 * 依赖: STM32 HAL (SPI1 主模式) ; main 先开启 SPI1 时钟与 GPIO 复用
 */
#include "w25q16.h"
#include "spi.h"            /* hspi1: 由 CubeMX 生成的 spi.c MX_SPI1_Init 初始化 */
#include "stm32f1xx_hal.h"

/* ---------- 底层 ---------- */
static void cs_low(void)  { HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_RESET); }
static void cs_high(void) { HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_SET); }

static uint8_t spi_txrx(uint8_t byte) {
  uint8_t r = 0;
  HAL_SPI_TransmitReceive(&hspi1, &byte, &r, 1, 100);
  return r;
}
static void spi_tx(const uint8_t *buf, uint32_t len) {
  HAL_SPI_Transmit(&hspi1, (uint8_t*)buf, len, 100);
}
static void spi_rx(uint8_t *buf, uint32_t len) {
  HAL_SPI_Receive(&hspi1, buf, len, 100);
}

static void wait_busy(void) {
  uint8_t st;
  uint32_t t0 = HAL_GetTick();
  cs_low();
  spi_txrx(W25X_ReadStatusReg1);
  do { st = spi_txrx(0xFF); } while ((st & 0x01) && (HAL_GetTick() - t0) < 500u); /* WIP, 超时防死 */
  cs_high();
}
static void write_enable(void) {
  cs_low();
  spi_txrx(W25X_WriteEnable);
  cs_high();
}

/* ---------- 公共 ---------- */
/* SPI1 初始化由 CubeMX 生成的 spi.c(MX_SPI1_Init)+gpio.c(PA4-CS) 完成
 * w25q16_init 已确保片选为高电平并完成实测, 如后续需变更请在此修改 */
void w25q16_init(void)
{
  /* hspi1 已在 MX_SPI1_Init 初始化; CS 已在 MX_GPIO_Init 拉高 */
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_4, GPIO_PIN_SET);
}

uint32_t w25q16_read_id(void)
{
  uint32_t id = 0;
  cs_low();
  spi_txrx(W25X_ReadJEDECID);
  id  = ((uint32_t)spi_txrx(0xFF)) << 16;
  id |= ((uint32_t)spi_txrx(0xFF)) << 8;
  id |= (uint32_t)spi_txrx(0xFF);
  cs_high();
  return id;
}

void w25q16_read(uint32_t addr, uint8_t *buf, uint32_t len)
{
  cs_low();
  spi_txrx(W25X_ReadData);
  spi_txrx((addr >> 16) & 0xFF);
  spi_txrx((addr >> 8)  & 0xFF);
  spi_txrx(addr & 0xFF);
  spi_rx(buf, len);
  cs_high();
}

void w25q16_erase_sector(uint32_t addr)
{
  write_enable();
  cs_low();
  spi_txrx(W25X_SectorErase);
  spi_txrx((addr >> 16) & 0xFF);
  spi_txrx((addr >> 8)  & 0xFF);
  spi_txrx(addr & 0xFF);
  cs_high();
  wait_busy();
}

void w25q16_page_program(uint32_t addr, const uint8_t *buf, uint32_t len)
{
  write_enable();
  cs_low();
  spi_txrx(W25X_PageProgram);
  spi_txrx((addr >> 16) & 0xFF);
  spi_txrx((addr >> 8)  & 0xFF);
  spi_txrx(addr & 0xFF);
  spi_tx(buf, len);
  cs_high();
  wait_busy();
}

void w25q16_write(uint32_t addr, const uint8_t *buf, uint32_t len)
{
  uint32_t offset = addr & (W25Q16_PAGE_SIZE - 1);
  uint32_t remain = len;
  const uint8_t *p = buf;

  if (offset) {
    uint32_t chunk = W25Q16_PAGE_SIZE - offset;
    if (chunk > remain) chunk = remain;
    w25q16_page_program(addr, p, chunk);
    p += chunk; remain -= chunk; addr += chunk;
  }
  while (remain > 0) {
    uint32_t chunk = (remain > W25Q16_PAGE_SIZE) ? W25Q16_PAGE_SIZE : remain;
    w25q16_page_program(addr, p, chunk);
    p += chunk; remain -= chunk; addr += chunk;
  }
}