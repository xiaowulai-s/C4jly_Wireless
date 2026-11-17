import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:c4f7n_protocol/c4f7n_protocol.dart';

void main() {
  group('CRC16-MODBUS', () {
    test('known vector "123456789" = 0x4B37', () {
      expect(crc16Modbus('123456789'.codeUnits), 0x4B37);
    });
  });

  group('spec section 7 test vectors (frozen CRC)', () {
    test('frame1: pump on', () {
      final f = buildFrame(Cmd.pump, [1]);
      expect(f, Uint8List.fromList([0xA5, 0x5A, 0x02, 0x20, 0x01, 0xD9, 0xB0]));
    });

    test('frame2: threshold read', () {
      final f = ParamReadRequest(ParamId.thrHi).encode();
      expect(f, Uint8List.fromList([0xA5, 0x5A, 0x03, 0x11, 0x01, 0x00, 0x20, 0x55]));
    });

    test('frame3: realtime report', () {
      final f = RealtimeFrame(
        concPpm: 12.4,
        tempC: 26.3,
        peakPpm: 18.2,
        battery: 86,
        deviceState: DevState.pumpOn,
        thrHiPpm: 50.0,
        uptimeS: 120,
      ).encode();
      expect(
        f,
        Uint8List.fromList([
          0xA5, 0x5A, 0x0F, 0x10, 0x7C, 0x00, 0x07, 0x01, 0xB6, 0x00, //
          0x56, 0x01, 0xF4, 0x01, 0x78, 0x00, 0x00, 0x00, 0x9E, 0xF2,
        ]),
      );
      // roundtrip
      final (pf, used) = tryParseFrame(f)!;
      expect(used, f.length);
      final rt = RealtimeFrame.decode(pf.payload);
      expect(rt.concPpm, 12.4);
      expect(rt.tempC, 26.3);
      expect(rt.peakPpm, 18.2);
      expect(rt.pumpOn, isTrue);
      expect(rt.thrHiPpm, 50.0);
    });

    test('frame4: heartbeat response', () {
      final f = HeartbeatResponse(
        battery: 86,
        deviceState: DevState.pumpOn | DevState.alarming,
        fwMajor: 4,
        fwMinor: 10,
        paramVer: 4,
      ).encode();
      expect(
        f,
        Uint8List.fromList([
          0xA5, 0x5A, 0x0E, 0x01, 0x00, 0x01, 0x00, 0x00, 0x56, 0x03, //
          0x04, 0x0A, 0x04, 0x00, 0x00, 0x00, 0x00, 0x75, 0x1F,
        ]),
      );
    });

    test('frame5: mute off', () {
      final f = MuteCommand(false).encode();
      expect(f, Uint8List.fromList([0xA5, 0x5A, 0x02, 0x21, 0x00, 0x19, 0xE0]));
    });
  });

  group('parser', () {
    test('skips garbage before header', () {
      final frame = buildFrame(Cmd.pump, [1]);
      final buf = [...[0x00, 0x11, 0x22], ...frame];
      final (pf, used) = tryParseFrame(buf)!;
      expect(pf.cmd, Cmd.pump);
      expect(used, buf.length);
    });

    test('returns null when incomplete', () {
      final frame = buildFrame(Cmd.pump, [1]);
      expect(tryParseFrame(frame.sublist(0, 5)), isNull);
    });

    test('throws on CRC mismatch', () {
      final frame = buildFrame(Cmd.pump, [1]);
      frame[frame.length - 1] ^= 0xFF;
      expect(() => tryParseFrame(frame), throwsA(isA<ProtocolException>()));
    });

    test('two frames in one buffer', () {
      final a = buildFrame(Cmd.pump, [1]);
      final b = MuteCommand(true).encode();
      final buf = [...a, ...b];
      final (f1, u1) = tryParseFrame(buf)!;
      final (f2, u2) = tryParseFrame(buf, offset: u1)!;
      expect(f1.cmd, Cmd.pump);
      expect(f2.cmd, Cmd.mute);
      expect(u2, buf.length);
    });
  });

  group('message roundtrips', () {
    test('param write', () {
      final f = ParamWriteRequest(ParamId.thrHi, 500).encode();
      final (pf, _) = tryParseFrame(f)!;
      final pv = ParamValue.decode(pf.payload);
      expect(pv.paramId, ParamId.thrHi);
      expect(pv.value, 500);
    });

    test('history batch with 2 points + last-frame marker', () {
      final batch = HistoryBatch([
        HistPoint(1700000000, 12),
        HistPoint(1700000001, 13),
      ]);
      final (pf, _) = tryParseFrame(batch.encode())!;
      final dec = HistoryBatch.decode(pf.payload);
      expect(dec.points.length, 2);
      expect(dec.points[0].ts, 1700000000);
      expect(dec.points[1].ppm, 13);
      expect(HistoryBatch([]).isLast, isTrue);
    });

    test('event frame', () {
      final (pf, _) = tryParseFrame(EventFrame(EventId.alarmStart, 1700000000).encode())!;
      final ev = EventFrame.decode(pf.payload);
      expect(ev.eventId, EventId.alarmStart);
      expect(ev.timestampS, 1700000000);
    });

    test('zero cal prepare result', () {
      final (pf, _) =
          tryParseFrame(ZeroCalPrepareResult(concPpm: 3.2, stable: true).encode())!;
      final r = ZeroCalPrepareResult.decode(pf.payload);
      expect(r.concPpm, 3.2);
      expect(r.stable, isTrue);
    });

    test('factory cal need-confirm flag', () {
      final f = FactoryCalResult(Err.needConfirm).encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(FactoryCalResult.decode(pf.payload).needConfirm, isTrue);
    });

    test('ack variants', () {
      expect(Ack.fromFrame(ParsedFrame(cmd: 0x20, payload: Uint8List(0))).ok, isTrue);
      expect(
        Ack.fromFrame(ParsedFrame(cmd: 0x20, payload: Uint8List.fromList([1]))).ok,
        isTrue,
      );
      final nack = Ack.fromFrame(ParsedFrame(cmd: 0x31, payload: Uint8List.fromList([0x03])));
      expect(nack.ok, isFalse);
      expect(nack.errCode, Err.noPermission);
    });

    test('heartbeat request', () {
      final f = HeartbeatRequest().encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(pf.cmd, Cmd.heartbeat);
      expect(pf.payload.length, 4);
      expect(rdU32(pf.payload, 0), protoVersion);
    });
  });

  group('limits', () {
    test('payload > 239 throws', () {
      expect(() => buildFrame(Cmd.realtime, List.filled(240, 0)),
          throwsArgumentError);
    });
    test('max size frame roundtrips', () {
      final f = buildFrame(Cmd.realtime, List.filled(239, 0x55));
      final (pf, used) = tryParseFrame(f)!;
      expect(used, 5 + 240);
      expect(pf.payload.length, 239);
    });
  });

  group('v1.1 maintenance (0x00) + auth rework', () {
    test('SN read request frame', () {
      final f = SnReadRequest().encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(pf.cmd, Cmd.maint);
      expect(pf.payload, [MaintOp.snRead]);
    });

    test('SN write request carries ascii SN', () {
      final f = SnWriteRequest('AB12').encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(pf.cmd, Cmd.maint);
      expect(pf.payload[0], MaintOp.snWrite);
      expect(String.fromCharCodes(pf.payload.sublist(1)), 'AB12');
      expect(() => SnWriteRequest(''), throwsArgumentError);
      expect(() => SnWriteRequest('X' * 25), throwsArgumentError);
    });

    test('SN read response decodes sn', () {
      final p = Uint8List.fromList(
          [MaintOp.snRead, ...'C4F7N-0001'.codeUnits]);
      final d = SnData.decode(p);
      expect(d!.sn, 'C4F7N-0001');
      expect(SnData.decode(Uint8List.fromList([0x02])), isNull);
    });

    test('auth hash set carries 32-byte sha256(password)', () {
      final f = AuthHashSetRequest('secret').encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(pf.cmd, Cmd.maint);
      expect(pf.payload[0], MaintOp.authHashSet);
      expect(pf.payload.length, 1 + 32);
    });

    test('v1.1 factory auth sends sha256(password) 32B', () {
      final f = FactoryAuthRequest('pw1').encode();
      final (pf, _) = tryParseFrame(f)!;
      expect(pf.cmd, Cmd.factoryAuth);
      expect(pf.payload.length, 32);
      // deterministic & password-sensitive
      final f2 = FactoryAuthRequest('pw2').encode();
      final (pf2, _) = tryParseFrame(f2)!;
      expect(pf2.payload, isNot(pf.payload));
    });
  });
}
