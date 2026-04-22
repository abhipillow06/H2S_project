// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  const HomeScreen({super.key, this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _qrScanned = false;
  String _userName = '';

  final Map<String, String> _roomData = {
    'roomNumber': '304',
    'floor': '3rd Floor',
    'staffName': 'Ravi Kumar',
    'staffId': 'STF-2041',
    'checkIn': 'Apr 18, 2026',
    'checkOut': 'Apr 21, 2026',
    'wifiName': 'StayEase_Hotel_5G',
    'wifiPass': 'Guest@2025',
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.055).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  Future<void> _loadUser() async {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      setState(() => _userName = widget.userName!);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('userName') ?? 'Guest');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Profile drawer ──────────────────────────────────────────────────────────
  void _openProfile() {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'G';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: kNavy,
                    child: Text(initial,
                        style: GoogleFonts.playfairDisplay(
                            color: kGold, fontSize: 36, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(_userName,
                      style: GoogleFonts.playfairDisplay(
                          color: kNavy, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGold, borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Hotel Guest',
                        style: GoogleFonts.lato(
                            color: kNavy, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ]),
              ),
              const SizedBox(height: 28),
              if (!_qrScanned) ...[
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorder),
                  ),
                  child: Column(children: [
                    Icon(Icons.lock_outline_rounded, color: Colors.grey[300], size: 52),
                    const SizedBox(height: 14),
                    Text('Room Details Locked',
                        style: GoogleFonts.lato(
                            color: kNavy, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Scan the QR code at check-in to view your room number, assigned staff, and WiFi access.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(color: kTextMid, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kNavy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                      ),
                      icon: const Icon(Icons.qr_code_scanner, color: kGold, size: 18),
                      label: Text('Scan QR to Unlock',
                          style: GoogleFonts.lato(
                              color: kWhite, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/qrcheckin').then((result) {
                          if (result == true) setState(() => _qrScanned = true);
                        });
                      },
                    ),
                  ]),
                ),
              ] else ...[
                SectionLabel('ROOM INFORMATION'),
                _tile(Icons.meeting_room_outlined, 'Room Number', _roomData['roomNumber']!),
                _tile(Icons.layers_outlined, 'Floor', _roomData['floor']!),
                _tile(Icons.login_outlined, 'Check-In', _roomData['checkIn']!),
                _tile(Icons.logout_outlined, 'Check-Out', _roomData['checkOut']!),
                const SizedBox(height: 18),
                SectionLabel('ASSIGNED STAFF'),
                _tile(Icons.person_outline_rounded, 'Staff Name', _roomData['staffName']!),
                _tile(Icons.badge_outlined, 'Staff ID', _roomData['staffId']!),
                const SizedBox(height: 18),
                SectionLabel('WIFI ACCESS'),
                _tile(Icons.wifi_outlined, 'Network', _roomData['wifiName']!),
                _tile(Icons.lock_open_outlined, 'Password', _roomData['wifiPass']!),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text('Room ${_roomData['roomNumber']} linked',
                        style: GoogleFonts.lato(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
                ),
              ],
              const SizedBox(height: 28),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18),
                label: Text('Logout',
                    style: GoogleFonts.lato(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(children: [
          Icon(icon, color: kGold, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.lato(color: kTextMid, fontSize: 11)),
              Text(value,
                  style: GoogleFonts.lato(
                      color: kNavy, fontWeight: FontWeight.w600, fontSize: 14)),
            ]),
          ),
        ]),
      );

  // ── Services list ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _services => [
        {
          'label': 'Check-In / Check-Out',
          'icon': Icons.qr_code_scanner_rounded,
          'color': kBlue,
          'sub': 'Scan QR to verify your room',
          'route': '/qrcheckin',
        },
        {
          'label': 'Room Service',
          'icon': Icons.room_service_outlined,
          'color': kTeal,
          'sub': 'Request towels, pillows & more',
          'route': '/roomservice',
        },
        {
          'label': 'Food Order',
          'icon': Icons.restaurant_menu_rounded,
          'color': const Color(0xFFFF8F00),
          'sub': 'Order from the hotel menu',
          'route': '/food',
        },
        {
          'label': 'WiFi Info',
          'icon': Icons.wifi_rounded,
          'color': kPurple,
          'sub': 'View network credentials',
          'route': '/wifi',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final initial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'G';

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kNavy,
              border: Border.all(color: kGold, width: 1.5),
            ),
            child: const Icon(Icons.domain, color: kGold, size: 17),
          ),
          const SizedBox(width: 10),
          Text('StayEase',
              style: GoogleFonts.playfairDisplay(
                  color: kNavy, fontWeight: FontWeight.bold, fontSize: 20)),
        ]),
        actions: [
          if (_qrScanned)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 13),
                const SizedBox(width: 4),
                Text('Room ${_roomData['roomNumber']}',
                    style: GoogleFonts.lato(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ]),
            ),
          GestureDetector(
            onTap: _openProfile,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: kNavy,
                child: Text(initial,
                    style: GoogleFonts.lato(
                        color: kGold, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $_userName',
                      style: GoogleFonts.playfairDisplay(
                          color: kNavy, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _qrScanned
                        ? 'Room ${_roomData['roomNumber']} • Tap your avatar for details'
                        : 'Scan your check-in QR to get started',
                    style: GoogleFonts.lato(color: kTextMid, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // QR banner (only if not checked in)
                  if (!_qrScanned) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/qrcheckin').then((result) {
                          if (result == true) setState(() => _qrScanned = true);
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: kNavy,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: kNavy.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded,
                                color: kGold, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Scan Check-In QR Code',
                                      style: GoogleFonts.lato(
                                          color: kWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(height: 3),
                                  Text('Tap to open scanner',
                                      style: GoogleFonts.lato(
                                          color: Colors.white38, fontSize: 12)),
                                ]),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.white38, size: 22),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  SectionLabel('SERVICES'),
                  ..._services.map((s) => GestureDetector(
                        onTap: () => Navigator.pushNamed(context, s['route'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: cardDecoration(),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (s['color'] as Color).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(s['icon'] as IconData,
                                  color: s['color'] as Color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s['label'] as String,
                                        style: GoogleFonts.lato(
                                            color: kNavy,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(s['sub'] as String,
                                        style: GoogleFonts.lato(
                                            color: kTextMid, fontSize: 12)),
                                  ]),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey[300], size: 22),
                          ]),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Emergency button pinned at bottom
          Container(
            color: kWhite,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/emergency'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B30), Color(0xFFB71C1C)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: kWhite, size: 26),
                      const SizedBox(width: 10),
                      Text('EMERGENCY SOS',
                          style: GoogleFonts.lato(
                              color: kWhite,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
