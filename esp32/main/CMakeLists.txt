idf_component_register(
    SRCS "main.c" "ble_gatt.c" "uart_bridge.c" "link_mon.c"
    INCLUDE_DIRS "."
    REQUIRES bt driver esp_timer nvs_flash log
)
