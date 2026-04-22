import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';


class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  String? _recordedPath;
  int _recordSeconds = 0;
  int _playSeconds = 0;
  int _totalSeconds = 0;
  Timer? _recTimer;
  Timer? _playTimer;

  // Waveform bars
  late AnimationController _waveCtrl;
  final List<double> _bars = List.generate(28, (_) => 0.15);
  final Random _rng = Random();
  Timer? _waveTimer;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
        if (state == PlayerState.completed) {
          _playTimer?.cancel();
          setState(() {
            _isPlaying = false;
            _playSeconds = 0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _playTimer?.cancel();
    _waveTimer?.cancel();
    _waveCtrl.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── Start recording ────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      _showSnack('Microphone permission denied');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/emergency_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordSeconds = 0;
      _recordedPath = null;
    });

    // Recording timer
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordSeconds++);
    });

    // Animated waveform
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted && _isRecording && !_isPaused) {
        setState(() {
          for (int i = 0; i < _bars.length; i++) {
            _bars[i] = 0.1 + _rng.nextDouble() * 0.9;
          }
        });
      }
    });
  }

  // ── Pause / Resume recording ───────────────────────────────────────────────
  Future<void> _togglePause() async {
    if (_isPaused) {
      await _recorder.resume();
      _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordSeconds++);
      });
    } else {
      await _recorder.pause();
      _recTimer?.cancel();
    }
    setState(() => _isPaused = !_isPaused);
  }

  // ── Stop recording ─────────────────────────────────────────────────────────
  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _recTimer?.cancel();
    _waveTimer?.cancel();

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordedPath = path;
      _totalSeconds = _recordSeconds;
    });

    // Reset bars to flat
    setState(() {
      for (int i = 0; i < _bars.length; i++) {
        _bars[i] = 0.15;
      }
    });
  }

  // ── Delete recording ───────────────────────────────────────────────────────
  void _deleteRecording() {
    _player.stop();
    setState(() {
      _recordedPath = null;
      _recordSeconds = 0;
      _totalSeconds = 0;
      _playSeconds = 0;
      _isPlaying = false;
      for (int i = 0; i < _bars.length; i++) {
        _bars[i] = 0.15;
      }
    });
  }

  // ── Play / Pause playback ──────────────────────────────────────────────────
  Future<void> _togglePlay() async {
    if (_recordedPath == null) return;
    if (_isPlaying) {
      await _player.pause();
      _playTimer?.cancel();
    } else {
      await _player.play(DeviceFileSource(_recordedPath!));
      _playSeconds = 0;
      _playTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _playSeconds++);
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _done() {
    if (_recordedPath != null) {
      Navigator.of(context).pop(_recordedPath);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kBgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Voice Report', style: GoogleFonts.playfairDisplay(color: kNavy, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          if (_recordedPath != null)
            TextButton(
              onPressed: _done,
              child: const Text(
                'Use',
                style: TextStyle(
                  color: kGold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreen.withOpacity(0.25)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.mic_rounded, color: kGreen, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Record a voice message describing the emergency. '
                      'Speak clearly and include key details.',
                      style: TextStyle(
                        fontSize: 11,
                        color: kGreen,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Waveform card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status label
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isRecording
                          ? (_isPaused ? '⏸  PAUSED' : '● RECORDING')
                          : (_recordedPath != null
                                ? '✓  RECORDED'
                                : 'READY TO RECORD'),
                      key: ValueKey(
                        _isRecording.toString() + _isPaused.toString(),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: _isRecording
                            ? (_isPaused ? Colors.orange : kRed)
                            : (_recordedPath != null ? kGreen : kTextMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timer
                  Text(
                    _isRecording
                        ? _fmt(_recordSeconds)
                        : (_recordedPath != null
                              ? (_isPlaying
                                    ? _fmt(_playSeconds)
                                    : _fmt(_totalSeconds))
                              : '00:00'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: _isRecording
                          ? kRed
                          : (_recordedPath != null ? kNavy : kTextMuted),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Waveform bars
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(_bars.length, (i) {
                        final active = _isRecording && !_isPaused;
                        final playActive =
                            _isPlaying &&
                            (i / _bars.length) <
                                (_playSeconds /
                                    (_totalSeconds == 0 ? 1 : _totalSeconds));
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          width: 5,
                          height:
                              60 *
                              (_isRecording && !_isPaused
                                  ? _bars[i]
                                  : (_recordedPath != null
                                        ? 0.3 + _bars[i] * 0.3
                                        : 0.15)),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: active
                                ? kRed.withOpacity(0.7 + _bars[i] * 0.3)
                                : (playActive ? kGreen : kBorder),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Controls
                  if (!_isRecording && _recordedPath == null) ...[
                    // Start button
                    _RecBtn(
                      icon: Icons.mic_rounded,
                      label: 'Start Recording',
                      color: kRed,
                      size: 64,
                      onTap: _startRecording,
                    ),
                  ] else if (_isRecording) ...[
                    // Pause + Stop
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RecBtn(
                          icon: _isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          label: _isPaused ? 'Resume' : 'Pause',
                          color: Colors.orange,
                          size: 52,
                          onTap: _togglePause,
                        ),
                        const SizedBox(width: 24),
                        _RecBtn(
                          icon: Icons.stop_rounded,
                          label: 'Stop',
                          color: kRed,
                          size: 64,
                          onTap: _stopRecording,
                        ),
                      ],
                    ),
                  ] else ...[
                    // Play + Delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RecBtn(
                          icon: Icons.delete_rounded,
                          label: 'Delete',
                          color: kTextMuted,
                          size: 48,
                          onTap: _deleteRecording,
                        ),
                        const SizedBox(width: 24),
                        _RecBtn(
                          icon: _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: _isPlaying ? 'Pause' : 'Play',
                          color: kGreen,
                          size: 64,
                          onTap: _togglePlay,
                        ),
                        const SizedBox(width: 24),
                        _RecBtn(
                          icon: Icons.mic_rounded,
                          label: 'Re-record',
                          color: kRed,
                          size: 48,
                          onTap: _deleteRecording,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tips ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFFF8F00),
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Recording Tips',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _TipItem(text: 'Speak clearly and at a normal pace'),
                  _TipItem(text: 'State your name and location first'),
                  _TipItem(text: 'Describe the emergency in detail'),
                  _TipItem(text: 'Mention number of people affected'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Use recording button ───────────────────────────────────────
            if (_recordedPath != null)
              GestureDetector(
                onTap: _done,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kGreen.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Use This Recording',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Record Button ────────────────────────────────────────────────────────────
class _RecBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _RecBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35), width: 2),
            ),
            child: Icon(icon, color: color, size: size * 0.42),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5D4037),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
