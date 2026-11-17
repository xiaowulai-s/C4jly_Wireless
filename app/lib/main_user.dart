import '../core/device_source.dart';
import '../state/device_controller.dart';
import '../ui/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    C4F7NApp(
      controller: DeviceController(MockDeviceSource()),
      factoryMode: false,
    ),
  );
}
