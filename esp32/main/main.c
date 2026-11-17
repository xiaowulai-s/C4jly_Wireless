/*
 * main.c - C4F7N BLE <-> UART transparent bridge (ESP32-S3, ESP-IDF v5.x).
 *
 * Role: transport layer only (spec docs/无线版开发方案与路线图_v1.md §2.2).
 *   phone --BLE--> [write char] --UART--> STM32
 *   STM32 --UART--> [frame assembly] --notify--> phone
 *
 * Wiring (see docs §3.2):
 *   ESP32 TX (GPIO17, menuconfig) -> STM32 PB7 (USART1_RX)
 *   ESP32 RX (GPIO18)             -> STM32 PB6 (USART1_TX)
 *   GND                           -> GND (must be common)
 */
#include <stdio.h>

#include "esp_log.h"
#include "nvs_flash.h"

#include "ble_gatt.h"
#include "uart_bridge.h"
#include "link_mon.h"

static const char *TAG = "main";

/* phone write-char -> downstream UART */
static void on_phone_write(const uint8_t *data, size_t len)
{
    uart_bridge_write(data, len);
}

void app_main(void)
{
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    link_mon_init();
    uart_bridge_init();
    ble_gatt_init(on_phone_write);

    ESP_LOGI(TAG, "C4F7N bridge up");
}
