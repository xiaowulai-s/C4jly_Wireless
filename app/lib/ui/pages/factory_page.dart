import 'package:c4f7n_protocol/c4f7n_protocol.dart' show FactoryCalOp;
import 'package:flutter/material.dart';

import '../../state/device_controller.dart';

/// Factory flavor: session auth (0x7A) -> calibration (0x31) / selftest (0x50)
/// / factory reset. Logic mirrors screen-version v79~v92 semantics.
class FactoryPage extends StatefulWidget {
  const FactoryPage({super.key, required this.controller});

  final DeviceController controller;

  @override
  State<FactoryPage> createState() => _FactoryPageState();
}

class _FactoryPageState extends State<FactoryPage> {
  final _pwd = TextEditingController();
  final _b = TextEditingController();
  final _k = TextEditingController();
  String _diag = '';

  bool get _connected => widget.controller.link == LinkState.connected;

  Future<void> _login() async {
    final ok = await widget.controller.unlockFactory(_pwd.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '厂家会话已开启' : '认证失败（口令错误或设备未连接）'),
    ));
  }

  Future<void> _cal(int op, String label) async {
    try {
      final r = await widget.controller.factoryCal(op);
      if (r == 1) {
        _diag = '$label 完成';
      } else if (r == 0x81) {
        _diag = '$label 需二次确认（应不到 20% 之外的变更场景）';
      } else {
        _diag = '$label 失败 NACK 0x${r.toRadixString(16)}';
      }
    } catch (e) {
      _diag = '$label 异常：$e';
    }
    if (mounted) setState(() {});
  }

  Future<void> _writeCompensation(int op, String label, TextEditingController c) async {
    final v = double.tryParse(c.text);
    if (v == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$label 需为数字')));
      return;
    }
    try {
      var r = await widget.controller.factoryCal(op, value: v);
      // >20% change: device asks for confirm -> resend with confirm=1
      if (r == 0x81) {
        final ok = await _confirmChange(label, v);
        if (!ok) {
          _diag = '$label 已取消';
          if (mounted) setState(() {});
          return;
        }
        r = await widget.controller.factoryCal(op, confirm: true, value: v);
      }
      _diag = r == 1 ? '$label 写入生效：$v' : '$label 失败 NACK 0x${r.toRadixString(16)}';
    } catch (e) {
      _diag = '$label 异常：$e';
    }
    if (mounted) setState(() {});
  }

  Future<bool> _confirmChange(String label, double v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('变更幅度超过 20%'),
        content: Text('$label 新值 $v，确认生效？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _selftest() async {
    try {
      final r = await widget.controller.selftest();
      _diag = '自检 0x${r.resultBits.toRadixString(16)} '
          '${r.allOk ? '全部正常' : '存在异常'} 错误码 ${r.errCodes}';
    } catch (e) {
      _diag = '自检异常：$e';
    }
    if (mounted) setState(() {});
  }

  Future<void> _factoryReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复出厂参数？'),
        content: const Text('标定与设置将全部恢复默认值（历史数据保留）。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('确认恢复')),
        ],
      ),
    );
    if (ok != true) return;
    final r = await widget.controller
        .factoryCal(FactoryCalOp.factoryReset, confirm: true);
    _diag = r == 1 ? '已恢复出厂参数' : '失败 NACK 0x${r.toRadixString(16)}';
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!widget.controller.factoryUnlocked) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 48, color: cs.outline),
                const SizedBox(height: 12),
                const Text('厂家会话未开启'),
                const SizedBox(height: 16),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _pwd,
                    obscureText: true,
                    enabled: _connected,
                    decoration: const InputDecoration(
                      labelText: '厂家口令',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _connected ? _login : null,
                  child: const Text('认证'),
                ),
                if (!_connected)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('请先连接设备', style: TextStyle(fontSize: 12, color: cs.outline)),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Chip(
            avatar: Icon(Icons.verified, size: 16, color: cs.primary),
            label: const Text('厂家会话已开启'),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('手动补偿（厂家页语义，20% 二次确认）',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _b,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(
                      labelText: '补偿 b（ppm，-200~200）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () =>
                        _writeCompensation(FactoryCalOp.writeManB, '补偿b', _b),
                    child: const Text('写入 b'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _k,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '补偿 k（千分比，100~10000）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () =>
                        _writeCompensation(FactoryCalOp.writeManK, '补偿k', _k),
                    child: const Text('写入 k'),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('标定与诊断', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _cal(FactoryCalOp.calSlope, '斜率标定'),
                        child: const Text('斜率标定'),
                      ),
                      OutlinedButton(
                        onPressed: () => _cal(FactoryCalOp.calOffset, '截距标定'),
                        child: const Text('截距标定'),
                      ),
                      OutlinedButton(
                        onPressed: _selftest,
                        child: const Text('自检'),
                      ),
                      OutlinedButton(
                        onPressed: _factoryReset,
                        child: const Text('恢复出厂'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_diag.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_diag, style: const TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
