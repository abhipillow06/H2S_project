// lib/screens/qr_checkin_screen.dart
// Adapted from Room-Entry-QR-Checkin-out-main — restyled to StayEase aesthetic
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../theme.dart';
import '../services/firebase_service.dart';
// ── Location helper ──────────────────────────────────────────────────────────
Future<String> _fetchLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'Location services disabled';
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return 'Location permission denied';
    }
    if (permission == LocationPermission.deniedForever) return 'Location permanently denied';
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

// ── QR Check-In Screen ───────────────────────────────────────────────────────
class QRCheckinScreen extends StatefulWidget {
  const QRCheckinScreen({super.key});

  @override
  State<QRCheckinScreen> createState() => _QRCheckinScreenState();
}

class _QRCheckinScreenState extends State<QRCheckinScreen> {
  late Timer _clockTimer;
  String _liveClock = '';

  String _mode = 'in';
  String _lastCheckIn = '--:--';
  String _lastCheckOut = '--:--';

  bool _showLocation = false;
  String _locationText = 'Fetching location…';
  bool _locationLoading = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _updateClock() {
    setState(() => _liveClock = DateFormat('hh:mm:ss a').format(DateTime.now()));
  }

  String _nowTime() => DateFormat('hh:mm a').format(DateTime.now());

  Future<void> _doCheckIn() async {
    final t = _nowTime();
    setState(() {
      _lastCheckIn = t;
      _mode = 'out';
      _showLocation = true;
      _locationLoading = true;
      _locationText = 'Fetching location…';
    });
    final loc = await _fetchLocation();
    if (mounted) {
      setState(() {
        _locationLoading = false;
        _locationText = loc;
      });
      _firebaseService.recordCheckInOut('Check In', t, loc);
      _showToast('Checked in at $t');
      // Return true to HomeScreen so it marks QR as scanned
      if (Navigator.canPop(context)) Navigator.pop(context, true);
    }
  }

  void _doCheckOut() {
    final t = _nowTime();
    setState(() {
      _lastCheckOut = t;
      _mode = 'in';
      _showLocation = false;
      _firebaseService.recordCheckInOut('Check Out', t, '');
    });
    _showToast('Checked out at $t');
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _QRScannerPage(mode: _mode),
        fullscreenDialog: true,
      ),
    );
    if (result != null) {
      if (_mode == 'in') {
        await _doCheckIn();
      } else {
        _doCheckOut();
      }
    }
  }

  // Toast
  OverlayEntry? _toastEntry;
  void _showToast(String msg) {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
        builder: (_) => _Toast(message: msg));
    Overlay.of(context).insert(_toastEntry!);
    Future.delayed(const Duration(milliseconds: 2600), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isIn = _mode == 'in';
    final accentColor = isIn ? kRed : kGreen;

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: stayEaseAppBar(title: 'Check-In / Check-Out'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('Today\'s Attendance',
                style: GoogleFonts.playfairDisplay(
                    color: kNavy, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(DateFormat('EEEE, d MMMM yyyy').format(now),
                style: GoogleFonts.lato(color: kTextMid, fontSize: 13)),
            const SizedBox(height: 20),

            // Status card
            Container(
              decoration: cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: IntrinsicHeight(
                child: Row(children: [
                  _StatusItem(label: 'CHECK IN', value: _lastCheckIn, color: kRed),
                  Container(width: 1, color: kBorder, margin: const EdgeInsets.symmetric(horizontal: 4)),
                  _StatusItem(label: 'CHECK OUT', value: _lastCheckOut, color: kGreen),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Live clock
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kNavy.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(children: [
                Icon(Icons.access_time_rounded, size: 14, color: kTextMid),
                const SizedBox(width: 8),
                Text(_liveClock,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: kNavy,
                        letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(height: 16),

            // Location box
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: _showLocation
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: kRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _locationLoading
                                ? Row(children: [
                                    const SizedBox(
                                      width: 11, height: 11,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: kTextMuted),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Fetching GPS location…',
                                        style: GoogleFonts.lato(fontSize: 12, color: kTextMuted)),
                                  ])
                                : RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Location: ',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: kNavy),
                                      ),
                                      TextSpan(
                                        text: _locationText,
                                        style: GoogleFonts.lato(fontSize: 12, color: kTextMid),
                                      ),
                                    ]),
                                  ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            if (_showLocation) const SizedBox(height: 16),

            // Scan card
            GestureDetector(
              onTap: _openQRScanner,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.045),
                      blurRadius: 12, offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 2.5),
                      borderRadius: BorderRadius.circular(14),
                      color: accentColor.withOpacity(0.06),
                    ),
                    child: Center(
                      child: Icon(Icons.qr_code_scanner_rounded, color: accentColor, size: 38),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isIn ? 'Tap to Check In' : 'Tap to Check Out',
                    style: GoogleFonts.lato(
                        color: accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Point camera at the hotel room QR code',
                      style: GoogleFonts.lato(color: kTextMid, fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Activity log
            SectionLabel('ACTIVITY LOG'),
            StreamBuilder<List<LogEntry>>(
              stream: _firebaseService.logStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kNavy)),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('Error loading logs: ${snapshot.error}', style: GoogleFonts.lato(color: kRed)),
                  );
                }

                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('No activity logs found.', style: GoogleFonts.lato(color: kTextMuted)),
                  );
                }

                return Column(
                  children: logs.map((e) => _LogEntryCard(entry: e)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatusItem({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final isSet = value != '--:--';
    return Expanded(
      child: Column(children: [
        Text(label, style: GoogleFonts.lato(fontSize: 11, color: kTextMuted, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: isSet ? color : kNavy)),
      ]),
    );
  }
}

class _LogEntryCard extends StatelessWidget {
  final LogEntry entry;
  const _LogEntryCard({super.key, required this.entry});
  @override
  Widget build(BuildContext context) {
    final isIn = entry.type == 'Check In';
    final color = isIn ? kRed : kGreen;
    final icon = isIn ? Icons.login_rounded : Icons.logout_rounded;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.type,
                style: GoogleFonts.lato(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
            Text('via QR Scan', style: GoogleFonts.lato(fontSize: 11, color: kTextMuted)),
            if (entry.location.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.location_on_rounded, size: 11, color: kTextMuted),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(entry.location,
                      style: GoogleFonts.lato(fontSize: 10, color: kTextMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ],
          ]),
        ),
        Text(entry.time,
            style: GoogleFonts.lato(fontSize: 13, color: kTextMid, letterSpacing: 0.3)),
      ]),
    );
  }
}

// ── QR Scanner Page ───────────────────────────────────────────────────────────
class _QRScannerPage extends StatefulWidget {
  final String mode;
  const _QRScannerPage({required this.mode});
  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _controller;
  StreamSubscription<Object?>? _subscription;
  bool _scanned = false;
  bool _torchOn = false;

  late AnimationController _lineAnim;
  late Animation<double> _linePos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
        formats: const [BarcodeFormat.qrCode], autoStart: false);
    _lineAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _linePos = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _lineAnim, curve: Curves.easeInOut));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.start();
      _subscription = _controller.barcodes.listen(_onBarcode);
    });
  }

  void _onBarcode(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _scanned = true;
    unawaited(_controller.stop());
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) Navigator.of(context).pop(raw);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _subscription?.cancel();
        unawaited(_controller.start());
        _subscription = _controller.barcodes.listen(_onBarcode);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _subscription?.cancel();
        unawaited(_controller.stop());
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lineAnim.dispose();
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = widget.mode == 'in';
    final accentColor = isCheckIn ? kGold : kGreen;
    final label = isCheckIn ? 'Scan to Check In' : 'Scan to Check Out';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onBarcode),
          _ScanOverlay(accentColor: accentColor, linePos: _linePos),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand in scanner
                      Row(children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: kNavy,
                            border: Border.all(color: kGold, width: 1.5),
                          ),
                          child: const Icon(Icons.domain, color: kGold, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Text('StayEase',
                            style: GoogleFonts.playfairDisplay(
                                color: kWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      Row(children: [
                        GestureDetector(
                          onTap: () {
                            _controller.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _torchOn
                                  ? kGold.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Icon(
                              _torchOn ? Icons.flashlight_on : Icons.flashlight_off_outlined,
                              color: kWhite, size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(null),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('Cancel',
                                style: GoogleFonts.lato(color: kWhite, fontSize: 14)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(children: [
                    Text(label,
                        style: GoogleFonts.lato(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3)),
                    const SizedBox(height: 6),
                    Text('Align the QR code within the frame',
                        style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scan overlay ─────────────────────────────────────────────────────────────
class _ScanOverlay extends StatelessWidget {
  final Color accentColor;
  final Animation<double> linePos;
  const _ScanOverlay({required this.accentColor, required this.linePos});

  @override
  Widget build(BuildContext context) {
    const boxSize = 240.0;
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final left = (sw - boxSize) / 2;
    final top = (sh - boxSize) / 2 - 30;

    return Stack(children: [
      Positioned(top: 0, left: 0, right: 0, height: top,
          child: const ColoredBox(color: Color(0xCC000000))),
      Positioned(top: top + boxSize, left: 0, right: 0, bottom: 0,
          child: const ColoredBox(color: Color(0xCC000000))),
      Positioned(top: top, left: 0, width: left, height: boxSize,
          child: const ColoredBox(color: Color(0xCC000000))),
      Positioned(top: top, left: left + boxSize, right: 0, height: boxSize,
          child: const ColoredBox(color: Color(0xCC000000))),
      Positioned(left: left, top: top, width: boxSize, height: boxSize,
          child: _CornerBrackets(color: accentColor)),
      AnimatedBuilder(
        animation: linePos,
        builder: (_, __) => Positioned(
          left: left + 8,
          top: top + linePos.value * boxSize,
          width: boxSize - 16, height: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, accentColor, Colors.transparent]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _CornerBrackets extends StatelessWidget {
  final Color color;
  const _CornerBrackets({required this.color});

  Widget _bracket({bool top = true, bool left = true}) {
    return SizedBox(
      width: 32, height: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: !top ? BorderSide(color: color, width: 3) : BorderSide.none,
            left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
            right: !left ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: 0, left: 0, child: _bracket(top: true, left: true)),
      Positioned(top: 0, right: 0, child: _bracket(top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _bracket(top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _bracket(top: false, left: false)),
    ]);
  }
}

// ── Toast widget ─────────────────────────────────────────────────────────────
class _Toast extends StatefulWidget {
  final String message;
  const _Toast({required this.message});
  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 48, left: 0, right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: kNavy,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Text(widget.message,
                  style: GoogleFonts.lato(color: kWhite, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
  }
}
