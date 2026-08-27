// One-off script: synthesizes short SFX tones and writes them as 16-bit PCM WAV files
// into assets/audio/sfx/. Run with `dart run tool/generate_sfx.dart` whenever the SFX
// set needs to be regenerated. No external dependencies.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int sampleRate = 44100;

/// A single tone segment: frequency sweeps linearly from [startFreq] to [endFreq]
/// over [duration] seconds, using [waveform] ('sine' | 'square' | 'triangle' | 'noise').
class ToneSegment {
  final double startFreq;
  final double endFreq;
  final double duration;
  final String waveform;
  final double amplitude;

  const ToneSegment(
    this.startFreq,
    this.endFreq,
    this.duration, {
    this.waveform = 'sine',
    this.amplitude = 1.0,
  });
}

List<double> _renderSegment(ToneSegment seg, Random rng) {
  final int n = (sampleRate * seg.duration).round();
  final samples = List<double>.filled(n, 0.0);
  double phase = 0.0;
  for (int i = 0; i < n; i++) {
    final t = i / sampleRate;
    final freq = seg.startFreq + (seg.endFreq - seg.startFreq) * (t / seg.duration);
    double value;
    switch (seg.waveform) {
      case 'square':
        value = sin(phase) >= 0 ? 1.0 : -1.0;
        break;
      case 'triangle':
        value = (2 / pi) * asin(sin(phase));
        break;
      case 'noise':
        value = rng.nextDouble() * 2 - 1;
        break;
      case 'sine':
      default:
        value = sin(phase);
    }
    samples[i] = value * seg.amplitude;
    phase += 2 * pi * freq / sampleRate;
  }
  return samples;
}

/// Applies a simple attack/decay envelope so tones don't click at the edges.
List<double> _envelope(List<double> samples, {double attack = 0.01, double release = 0.05}) {
  final n = samples.length;
  final attackSamples = (sampleRate * attack).round().clamp(0, n);
  final releaseSamples = (sampleRate * release).round().clamp(0, n);
  final out = List<double>.from(samples);
  for (int i = 0; i < attackSamples; i++) {
    out[i] *= i / attackSamples;
  }
  for (int i = 0; i < releaseSamples; i++) {
    final idx = n - 1 - i;
    if (idx < 0) break;
    out[idx] *= i / releaseSamples;
  }
  return out;
}

Uint8List _buildWav(List<double> samples) {
  final data = Int16List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    data[i] = (clamped * 32767).round();
  }
  final byteData = ByteData(44 + data.lengthInBytes);
  final byteRate = sampleRate * 2;
  int o = 0;
  void writeString(String s) {
    for (final c in s.codeUnits) {
      byteData.setUint8(o++, c);
    }
  }

  writeString('RIFF');
  byteData.setUint32(o, 36 + data.lengthInBytes, Endian.little);
  o += 4;
  writeString('WAVE');
  writeString('fmt ');
  byteData.setUint32(o, 16, Endian.little);
  o += 4;
  byteData.setUint16(o, 1, Endian.little); // PCM
  o += 2;
  byteData.setUint16(o, 1, Endian.little); // mono
  o += 2;
  byteData.setUint32(o, sampleRate, Endian.little);
  o += 4;
  byteData.setUint32(o, byteRate, Endian.little);
  o += 4;
  byteData.setUint16(o, 2, Endian.little); // block align
  o += 2;
  byteData.setUint16(o, 16, Endian.little); // bits per sample
  o += 2;
  writeString('data');
  byteData.setUint32(o, data.lengthInBytes, Endian.little);
  o += 4;
  for (int i = 0; i < data.length; i++) {
    byteData.setInt16(o, data[i], Endian.little);
    o += 2;
  }
  return byteData.buffer.asUint8List();
}

void writeSfx(String name, List<ToneSegment> segments, {int seed = 1}) {
  final rng = Random(seed);
  final all = <double>[];
  for (final seg in segments) {
    all.addAll(_envelope(_renderSegment(seg, rng)));
  }
  final file = File('assets/audio/sfx/$name.wav');
  file.createSync(recursive: true);
  file.writeAsBytesSync(_buildWav(all));
  stdout.writeln('wrote ${file.path} (${all.length} samples)');
}

void main() {
  // Bubble collect: quick rising blip.
  writeSfx('bubble_collect', [
    const ToneSegment(500, 950, 0.10, amplitude: 0.5),
  ]);

  // Pearl collect: bright two-note chime.
  writeSfx('pearl_collect', [
    const ToneSegment(900, 900, 0.10, amplitude: 0.5),
    const ToneSegment(1350, 1350, 0.16, amplitude: 0.45),
  ]);

  // Generic power-up activation: rising sweep.
  writeSfx('powerup_activate', [
    const ToneSegment(300, 1100, 0.30, amplitude: 0.5),
  ]);

  // Shield: soft shimmering rise, slower attack.
  writeSfx('shield_activate', [
    const ToneSegment(500, 700, 0.18, waveform: 'triangle', amplitude: 0.4),
    const ToneSegment(700, 1000, 0.22, waveform: 'triangle', amplitude: 0.4),
  ]);

  // Magnet: pulsing tone (two short pulses).
  writeSfx('magnet_activate', [
    const ToneSegment(600, 600, 0.08, amplitude: 0.45),
    const ToneSegment(0, 0, 0.03, amplitude: 0.0),
    const ToneSegment(800, 800, 0.10, amplitude: 0.45),
  ]);

  // Speed boost: fast ascending sweep.
  writeSfx('speed_boost', [
    const ToneSegment(400, 1600, 0.22, waveform: 'square', amplitude: 0.3),
  ]);

  // Slow motion: descending soft sweep.
  writeSfx('slow_motion', [
    const ToneSegment(900, 350, 0.35, waveform: 'triangle', amplitude: 0.4),
  ]);

  // Pearl multiplier: bright sparkle arpeggio.
  writeSfx('pearl_multiplier', [
    const ToneSegment(700, 700, 0.08, amplitude: 0.4),
    const ToneSegment(1050, 1050, 0.08, amplitude: 0.4),
    const ToneSegment(1400, 1400, 0.12, amplitude: 0.4),
  ]);

  // Shark warning: low ominous pulses.
  writeSfx('shark_warning', [
    const ToneSegment(180, 160, 0.16, waveform: 'square', amplitude: 0.35),
    const ToneSegment(0, 0, 0.05, amplitude: 0.0),
    const ToneSegment(180, 150, 0.18, waveform: 'square', amplitude: 0.35),
  ]);

  // Crash: noise burst + descending thud.
  writeSfx('crash', [
    const ToneSegment(0, 0, 0.05, waveform: 'noise', amplitude: 0.6),
    const ToneSegment(220, 60, 0.30, waveform: 'triangle', amplitude: 0.5),
  ]);

  // Button click: very short tick.
  writeSfx('button_click', [
    const ToneSegment(900, 700, 0.04, amplitude: 0.35),
  ]);

  // Game start: three ascending notes.
  writeSfx('game_start', [
    const ToneSegment(523, 523, 0.10, amplitude: 0.45),
    const ToneSegment(659, 659, 0.10, amplitude: 0.45),
    const ToneSegment(784, 784, 0.18, amplitude: 0.45),
  ]);

  // Game over: descending sad sweep.
  writeSfx('game_over', [
    const ToneSegment(500, 260, 0.22, waveform: 'triangle', amplitude: 0.45),
    const ToneSegment(260, 140, 0.30, waveform: 'triangle', amplitude: 0.4),
  ]);

  // Countdown tick / go.
  writeSfx('countdown_tick', [
    const ToneSegment(700, 700, 0.08, amplitude: 0.4),
  ]);
  writeSfx('countdown_go', [
    const ToneSegment(950, 950, 0.14, amplitude: 0.5),
  ]);
}
