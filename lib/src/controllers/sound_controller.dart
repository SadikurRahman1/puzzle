import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class SoundController extends GetxController {
  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();

  late final Uint8List _moveSound;
  late final Uint8List _winSound;

  @override
  void onInit() {
    super.onInit();
    _moveSound = _generateToneWav(frequency: 660, durationMs: 46, volume: 0.42);
    _winSound = _generateToneWav(frequency: 740, durationMs: 90, volume: 0.46);
  }

  Future<void> playMove() async {
    await _movePlayer.stop();
    await _movePlayer.play(BytesSource(_moveSound), volume: 1.0);
  }

  Future<void> playWin() async {
    await _winPlayer.stop();
    await _winPlayer.play(BytesSource(_winSound), volume: 1.0);
  }

  Uint8List _generateToneWav({
    required double frequency,
    required int durationMs,
    required double volume,
    int sampleRate = 44100,
  }) {
    final BytesBuilder pcm = BytesBuilder();
    final int sampleCount = (sampleRate * (durationMs / 1000)).round();

    for (int i = 0; i < sampleCount; i++) {
      final double t = i / sampleRate;
      final double fade = _fadeEnvelope(i, sampleCount);
      final double wave = sin(2 * pi * frequency * t) * volume * fade;
      final int sample = (wave * 32767).clamp(-32768, 32767).toInt();
      final int encoded = sample & 0xFFFF;
      pcm.add(<int>[encoded & 0xFF, (encoded >> 8) & 0xFF]);
    }

    final Uint8List pcmBytes = pcm.toBytes();
    final int dataSize = pcmBytes.length;
    final int byteRate = sampleRate * 2;
    final BytesBuilder wav = BytesBuilder();

    void writeAscii(String value) => wav.add(value.codeUnits);
    void writeUint32(int value) => wav.add(<int>[
          value & 0xFF,
          (value >> 8) & 0xFF,
          (value >> 16) & 0xFF,
          (value >> 24) & 0xFF,
        ]);
    void writeUint16(int value) => wav.add(<int>[value & 0xFF, (value >> 8) & 0xFF]);

    writeAscii('RIFF');
    writeUint32(36 + dataSize);
    writeAscii('WAVE');
    writeAscii('fmt ');
    writeUint32(16);
    writeUint16(1);
    writeUint16(1);
    writeUint32(sampleRate);
    writeUint32(byteRate);
    writeUint16(2);
    writeUint16(16);
    writeAscii('data');
    writeUint32(dataSize);
    wav.add(pcmBytes);

    return wav.toBytes();
  }

  double _fadeEnvelope(int index, int total) {
    final double progress = index / total;
    if (progress < 0.08) return progress / 0.08;
    if (progress > 0.9) return (1 - progress) / 0.1;
    return 1;
  }

  @override
  void onClose() {
    _movePlayer.dispose();
    _winPlayer.dispose();
    super.onClose();
  }
}