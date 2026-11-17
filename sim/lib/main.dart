import 'package:flutter/material.dart';

import 'sim_device.dart';

void main() => runApp(const SimApp());

class SimApp extends StatelessWidget {
  const SimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'C4F7N Sim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SimHomePage(),
    );
  }
}

class SimHomePage extends StatefulWidget {
  const SimHomePage({super.key});

  @override
  State<SimHomePage> createState() => _SimHomePageState();
}

class _SimHomePageState extends State<SimHomePage> {
  final SimDevice _dev = SimDevice();
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _dev.start();
    if (!mounted) return;
    setState(() => _started = true);
    // refresh UI at 2 Hz (data ticks at 1 Hz inside SimDevice)
    Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _dev.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('C4F7N 模拟器 · C4F7N-${_dev.deviceIdHex}'),
        backgroundColor: cs.surfaceContainerHighest,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _statusCard(cs),
          const SizedBox(height: 10),
          _advertiseCard(cs),
          const SizedBox(height: 10),
          _scenarioCard(cs),
          const SizedBox(height: 10),
          _controlCard(cs),
          const SizedBox(height: 10),
          _logCard(cs),
        ],
      ),
    );
  }

  Widget _statusCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              _dev.conc.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w500,
                color: _dev.alarming ? cs.error : cs.primary,
              ),
            ),
            const Text('ppm（模拟浓度）'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _chip('峰值 ${_dev.peak.toStringAsFixed(1)}'),
                _chip('电量 ${_dev.battery}%'),
                _chip('泵 ${_dev.pumpOn ? '开' : '关'}'),
                _chip('报警 ${_dev.alarming ? '是' : '否'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String s) =>
      Chip(label: Text(s, style: const TextStyle(fontSize: 12)));

  Widget _advertiseCard(ColorScheme cs) {
    return Card(
      child: SwitchListTile(
        title: Text(_dev.advertising ? '广播中：C4F7N-${_dev.deviceIdHex}' : '未广播'),
        subtitle: Text(_started ? '服务已就绪' : '初始化中...'),
        value: _dev.advertising,
        onChanged: _started
            ? (v) async {
                if (v) {
                  await _dev.startAdvertise();
                } else {
                  await _dev.stopAdvertise();
                }
                setState(() {});
              }
            : null,
      ),
    );
  }

  Widget _scenarioCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('浓度场景'),
            ),
            RadioListTile<Scenario>(
              title: const Text('稳定 (~3 ppm)'),
              value: Scenario.stable,
              groupValue: _dev.scenario,
              onChanged: (v) => setState(() => _dev.scenario = v!),
            ),
            RadioListTile<Scenario>(
              title: const Text('爬升报警（约 1 分钟内超阈值）'),
              value: Scenario.rampAlarm,
              groupValue: _dev.scenario,
              onChanged: (v) => setState(() => _dev.scenario = v!),
            ),
            RadioListTile<Scenario>(
              title: const Text('周期尖峰（30s 循环，峰值 ~63 ppm）'),
              value: Scenario.spike,
              groupValue: _dev.scenario,
              onChanged: (v) => setState(() => _dev.scenario = v!),
            ),
            ListTile(
              title: Text('报警阈值：${(_dev.thrHi / 10).toStringAsFixed(1)} ppm'),
              subtitle: Slider(
                min: 100,
                max: 1000,
                divisions: 90,
                value: _dev.thrHi.toDouble().clamp(100, 1000),
                label: (_dev.thrHi / 10).toStringAsFixed(1),
                onChanged: (v) => setState(() => _dev.thrHi = v.round()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlCard(ColorScheme cs) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('泵'),
            value: _dev.pumpOn,
            onChanged: (v) => setState(() => _dev.pumpOn = v),
          ),
          SwitchListTile(
            title: const Text('静音'),
            value: _dev.muted,
            onChanged: (v) => setState(() => _dev.muted = v),
          ),
          ListTile(
            title: const Text('电量回满'),
            trailing: const Icon(Icons.battery_full),
            onTap: () => setState(() => _dev.battery = 100),
          ),
        ],
      ),
    );
  }

  Widget _logCard(ColorScheme cs) {
    return Card(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _dev.logLines.length,
          itemBuilder: (_, i) => Text(
            _dev.logLines[i],
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
