/*
 * link_mon.c - UART silence watchdog.
 *
 * The STM32 must be talking continuously (1 Hz realtime frames). If the
 * downstream goes silent beyond CONFIG_C4F7N_UART_SILENCE_MS we log it so the
 * bench tester sees it immediately; the phone gets silent too (no realtime
 * frames -> its 15 s heartbeat timeout path handles the UI side).
 */
#include "link_mon.h"

#include <string.h>

#include "esp_timer.h"
#include "esp_log.h"

static const char *TAG = "link_mon";

static volatile int64_t s_last_rx_ms;
static esp_timer_handle_t s_timer;

static void check_cb(void *arg)
{
    (void)arg;
#if CONFIG_C4F7N_UART_SILENCE_MS > 0
    int64_t now = esp_timer_get_time() / 1000;
    int64_t silent = now - s_last_rx_ms;
    if (silent > CONFIG_C4F7N_UART_SILENCE_MS) {
        ESP_LOGW(TAG, "STM32 link silent %lld ms", (long long)silent);
    }
#endif
}

void link_mon_init(void)
{
    s_last_rx_ms = esp_timer_get_time() / 1000;
    const esp_timer_create_args_t args = {
        .callback = check_cb,
        .name = "link_mon",
    };
    ESP_ERROR_CHECK(esp_timer_create(&args, &s_timer));
    ESP_ERROR_CHECK(esp_timer_start_periodic(s_timer, 5000 * 1000));
}

void link_mon_mark_uart_rx(void)
{
    s_last_rx_ms = esp_timer_get_time() / 1000;
}
