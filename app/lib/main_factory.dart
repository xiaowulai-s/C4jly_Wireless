import '../core/device_source.dart';
import '../state/device_controller.dart';
import '../ui/app.dart';
import 'package:flutter/material.dart';

/// factory flavor entry: same shell + 厂家 tab (Phase 3 wires 0x31 commands).
void main() {
  runApp(
    C4F7NApp(
      controller: DeviceController(MockDeviceSource()),
      factoryMode: true,
    ),
  );
}
