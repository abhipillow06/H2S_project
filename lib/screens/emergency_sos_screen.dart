// lib/screens/emergency_sos_screen.dart
// Adapted from Room-Emergency-SOS-main — restyled to StayEase aesthetic
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme.dart';
import '../models/emergency_report.dart';
import '../pages/text_report_page.dart';
import '../pages/camera_page.dart';
import '../pages/voice_page.dart';
import '../pages/submit_page.dart';

// ── Location helper ──────────────────────────────────────────────────────────
Future<String> _fetchLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Location services disabled';
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return 'Permission denied';
    }
    if (permission == LocationPermission.deniedForever) return 'Permission permanently denied';
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (marks.isNotEmpty) {
      final p = marks.first;
      final parts = <String>[
        if ((p.thoroughfare ?? '').isNotEmpty) p.thoroughfare!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
      ];
      return parts.join(', ');
    }
    return '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
  } catch (_) {
    return 'Unable to fetch location';
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class EmergencySOSScreen extends StatefulWidget {
  const EmergencySOSScreen({super.key});

  @override
  State<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen>
    with TickerProviderStateMixin {
  // Clock
  late Timer _clockTimer;
  String _liveClock = '';

  // SOS state
  bool _sosSent = false;
  bool _sosCountdown = false;
  int _countdownVal = 3;
  Timer? _countdownTimer;

  // Location
  String _location = 'Tap SOS to broadcast your location';
  bool _locationLoading = false;

  // Report
  final EmergencyReport _report = EmergencyReport();

  // Animations
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_ringCtrl);
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _countdownTimer?.cancel();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  void _updateClock() {
    setState(() => _liveClock = DateFormat('hh:mm:ss a').format(DateTime.now()));
  }

  void _onSOSPressed() {
    if (_sosSent) return;
    if (_sosCountdown) {
      _countdownTimer?.cancel();
      _ringCtrl.reset();
      setState(() { _sosCountdown = false; _countdownVal = 3; });
      return;
    }
    setState(() { _sosCountdown = true; _countdownVal = 3; });
    _ringCtrl.forward(from: 0);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdownVal--);
      if (_countdownVal <= 0) { t.cancel(); _triggerSOS(); }
    });
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _sosCountdown = false;
      _sosSent = true;
      _locationLoading = true;
      _location = 'Fetching GPS location…';
      _report.timestamp = DateTime.now();
    });
    final loc = await _fetchLocation();
    if (mounted) {
      setState(() {
        _locationLoading = false;
        _location = loc;
        _report.location = loc;
      });
    }
  }

  void _resetSOS() {
    setState(() {
      _sosSent = false;
      _sosCountdown = false;
      _countdownVal = 3;
      _locationLoading = false;
      _location = 'Tap SOS to broadcast your location';
      _report.location = null;
      _report.timestamp = null;
    });
    _ringCtrl.reset();
  }

  Future<void> _openTextReport() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => TextReportPage(report: _report)),
    );
    if (result != null) setState(() => _report.textReport = result);
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const CameraCapturePage()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _report.mediaPaths.addAll(result));
    }
  }

  Future<void> _openVoice() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const VoicePage()),
    );
    if (result != null) setState(() => _report.voiceMemoPath = result);
  }

  void _openSubmit() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SubmitPage(report: _report, onReset: _resetSOS)),
    );
  }

  String get _statusLabel {
    if (_sosCountdown) return 'SENDING IN $_countdownVal… TAP TO CANCEL';
    if (_sosSent) return 'SOS BROADCAST ACTIVE';
    return 'STANDBY — TAP TO ACTIVATE';
  }

  Color get _statusColor {
    if (_sosCountdown) return kOrange;
    if (_sosSent) return kRed;
    return kTextMuted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: _sosSent ? kRed : kWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: _sosSent ? kWhite : kNavy),
        title: Text(
          _sosSent ? '🚨 SOS ACTIVE' : 'Emergency SOS',
          style: GoogleFonts.playfairDisplay(
              color: _sosSent ? kWhite : kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Hero card
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: _sosSent ? kRed : kWhite,
                border: Border.all(color: _sosSent ? kRed : kBorder),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_sosSent ? kRed : Colors.black).withOpacity(0.10),
                    blurRadius: 16, offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(children: [
                Text(
                  _sosSent ? 'Emergency broadcast is active' : 'Press to send emergency alert',
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      color: _sosSent ? Colors.white70 : kTextMid),
                ),
                const SizedBox(height: 24),
                // SOS button
                GestureDetector(
                  onTap: _onSOSPressed,
                  child: ScaleTransition(
                    scale: _sosSent ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: SizedBox(
                      width: 140, height: 140,
                      child: Stack(alignment: Alignment.center, children: [
                        if (_sosCountdown)
                          AnimatedBuilder(
                            animation: _ringAnim,
                            builder: (_, __) => SizedBox(
                              width: 140, height: 140,
                              child: CircularProgressIndicator(
                                value: _ringAnim.value,
                                strokeWidth: 5,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation(kOrange),
                              ),
                            ),
                          ),
                        Container(
                          width: 130, height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _sosSent
                                ? Colors.white.withOpacity(0.15)
                                : kRed.withOpacity(0.12),
                          ),
                        ),
                        Container(
                          width: 108, height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _sosSent ? kWhite : kRed,
                            boxShadow: [
                              BoxShadow(
                                color: kRed.withOpacity(0.45),
                                blurRadius: 24, spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _sosCountdown
                                ? Text('$_countdownVal',
                                    style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        color: _sosSent ? kRed : kWhite))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('SOS',
                                          style: GoogleFonts.lato(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w900,
                                              color: _sosSent ? kRed : kWhite,
                                              letterSpacing: 2)),
                                      Text(_sosSent ? 'SENT' : 'TAP',
                                          style: GoogleFonts.lato(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _sosSent
                                                  ? kRed.withOpacity(0.7)
                                                  : Colors.white70,
                                              letterSpacing: 2)),
                                    ],
                                  ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(_sosSent ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(_statusLabel,
                      style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _sosSent ? kWhite : _statusColor,
                          letterSpacing: 0.8)),
                ),
                const SizedBox(height: 16),
                // Clock & location
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _sosSent ? Colors.white.withOpacity(0.12) : kBgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _sosSent ? Colors.white.withOpacity(0.2) : kBorder,
                    ),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: _sosSent ? Colors.white70 : kTextMuted),
                      const SizedBox(width: 6),
                      Text(_liveClock,
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              color: _sosSent ? kWhite : kTextMid)),
                    ]),
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.location_on_rounded,
                          size: 13, color: _sosSent ? Colors.white70 : kRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _locationLoading
                            ? Row(children: [
                                SizedBox(
                                  width: 10, height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: _sosSent ? kWhite : kTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Fetching GPS…',
                                    style: GoogleFonts.lato(
                                        fontSize: 11,
                                        color: _sosSent ? Colors.white70 : kTextMuted)),
                              ])
                            : Text(_location,
                                style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: _sosSent ? kWhite : kTextMid)),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 24),
            SectionLabel('BUILD YOUR REPORT'),

            // Action cards
            _actionCard(
              icon: Icons.edit_note_rounded,
              iconColor: kBlue,
              title: 'Write Incident Report',
              subtitle: _report.hasText
                  ? '${_report.textReport.length} chars · ${_report.disasterType} · ${_report.severity}'
                  : 'Describe what happened, type & severity',
              done: _report.hasText,
              doneColor: kBlue,
              onTap: _openTextReport,
            ),
            const SizedBox(height: 10),
            _actionCard(
              icon: Icons.camera_alt_rounded,
              iconColor: kOrange,
              title: 'Attach Photos & Videos',
              subtitle: _report.hasMedia
                  ? '${_report.mediaPaths.length} file(s) attached'
                  : 'Camera, gallery, or record video',
              done: _report.hasMedia,
              doneColor: kOrange,
              onTap: _openCamera,
            ),
            const SizedBox(height: 10),
            _actionCard(
              icon: Icons.mic_rounded,
              iconColor: kGreen,
              title: 'Record Voice Memo',
              subtitle: _report.hasVoice ? 'Voice memo recorded ✓' : 'Send a voice message',
              done: _report.hasVoice,
              doneColor: kGreen,
              onTap: _openVoice,
            ),

            // Media strip
            if (_report.hasMedia) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _report.mediaPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: kBorder,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(Icons.image_rounded, color: kTextMuted, size: 28),
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _report.mediaPaths.removeAt(i)),
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: kWhite, size: 13),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Summary row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: cardDecoration(radius: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem(Icons.edit_note_rounded, 'Report', _report.hasText, kBlue),
                  _vDivider(),
                  _summaryItem(Icons.camera_alt_rounded, '${_report.mediaPaths.length} Media', _report.hasMedia, kOrange),
                  _vDivider(),
                  _summaryItem(Icons.mic_rounded, 'Voice', _report.hasVoice, kGreen),
                  _vDivider(),
                  _summaryItem(Icons.location_on_rounded, 'Location', _report.hasLocation, kRed),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Submit button
            GestureDetector(
              onTap: _sosSent ? _openSubmit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _sosSent ? kRed : kBorder,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _sosSent
                      ? [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
                      : [],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.send_rounded, color: _sosSent ? kWhite : kTextMuted, size: 18),
                  const SizedBox(width: 8),
                  Text('SUBMIT EMERGENCY REPORT',
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _sosSent ? kWhite : kTextMuted,
                          letterSpacing: 0.8)),
                ]),
              ),
            ),
            if (!_sosSent)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text('Activate SOS first before submitting',
                      style: GoogleFonts.lato(fontSize: 11, color: kTextMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool done,
    required Color doneColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: cardDecoration(),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.lato(
                      fontSize: 14, fontWeight: FontWeight.w600, color: kNavy)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.lato(fontSize: 11, color: kTextMuted),
                  maxLines: 2),
            ]),
          ),
          const SizedBox(width: 8),
          done
              ? Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                      color: doneColor.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.check_rounded, color: doneColor, size: 15))
              : Icon(Icons.chevron_right_rounded, color: kTextLight, size: 20),
        ]),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, bool done, Color color) {
    return Column(children: [
      Icon(icon, size: 18, color: done ? color : kTextLight),
      const SizedBox(height: 3),
      Text(label,
          style: GoogleFonts.lato(
              fontSize: 10,
              color: done ? color : kTextLight,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
    ]);
  }

  Widget _vDivider() =>
      Container(width: 1, height: 30, color: kBorder);
}
