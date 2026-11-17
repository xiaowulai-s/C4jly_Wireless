/*
 * ble_gatt.h - NimBLE GATT server for C4F7N protocol v1 bridge.
 *
 * Service 48B5C976-CAE8-4BA4-9D6C-F560D9958777
 *   char ...4BA5  Write Without Response  (phone -> device)
 *   char ...4BA6  Read + Notify           (device -> phone)
 *
 * The bridge does NOT interpret frames: bytes written from the phone go to
 * the UART; bytes from the UART are notified to subscribers (spec docs/协议v1.md §4.6).
 */
#ifndef BLE_GATT_H
#define BLE_GATT_H

#include <stdint.h>
#include <stddef.h>

/* called from the NimBLE host task when the phone writes the write-char */
typedef void (*ble_gatt_write_cb_t)(const uint8_t *data, size_t len);

void ble_gatt_init(ble_gatt_write_cb_t on_write);

/* forward downstream bytes to a subscribed phone; chunks to current MTU-3.
 * Returns number of bytes actually queued (0 if nobody subscribed). */
size_t ble_gatt_send_to_ble(const uint8_t *data, size_t len);

#endif /* BLE_GATT_H */
