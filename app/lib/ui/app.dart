import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../state/device_controller.dart';
import 'pages/connect_page.dart';
import 'pages/factory_page.dart';
import 'pages/guide_page.dart';
import 'pages/measure_page.dart';
import 'pages/settings_page.dart';
import 'pages/task_page.dart';

/// Root shell with bottom navigation. `factory` flavor adds a 厂家 tab.
class C4F7NApp extends StatefulWidget {
  const C4F7NApp({
    super.key,
    required this.controller,
    this.factoryMode = false,
  });

  final DeviceController controller;
  final bool factoryMode;

  @override
  State<C4F7NApp> createState() => _C4F7NAppState();
}

class _C4F7NAppState extends State<C4F7NApp> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // notification init + favorites/theme bootstrap
    widget.controller.bootstrap();
    _maybeShowGuide();
  }

  Future<void> _maybeShowGuide() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await showGuideIfNeeded(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final pages = <Widget>[
          MeasurePage(controller: widget.controller),
          const TaskPage(),
          ConnectPage(controller: widget.controller),
          SettingsPage(controller: widget.controller),
        ];
        final destinations = <NavigationDestination>[
          const NavigationDestination(icon: Icon(Icons.speed), label: '测量'),
          const NavigationDestination(icon: Icon(Icons.assignment), label: '任务'),
          const NavigationDestination(icon: Icon(Icons.sensors), label: '设备'),
          const NavigationDestination(icon: Icon(Icons.tune), label: '设置'),
        ];
        if (widget.factoryMode) {
          pages.add(FactoryPage(controller: widget.controller));
          destinations.add(const NavigationDestination(
            icon: Icon(Icons.build),
            label: '厂家',
          ));
        }
        final tab = _tab.clamp(0, pages.length - 1);
        return MaterialApp(
          title: 'C4F7N 检漏仪',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: widget.controller.themeMode,
          home: WithForegroundTask(
            child: Scaffold(
              body: IndexedStack(index: tab, children: pages),
              bottomNavigationBar: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (i) => setState(() => _tab = i),
                destinations: destinations,
              ),
            ),
          ),
        );
      },
    );
  }
}
