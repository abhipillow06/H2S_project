import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emergency_report.dart';
import 'package:url_launcher/url_launcher.dart';











class SubmitPage extends StatefulWidget {
  final EmergencyReport report;
  final VoidCallback onReset;
  const SubmitPage({super.key, required this.report, required this.onReset});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage>
    with SingleTickerProviderStateMixin {
  bool _submitted = false;
  bool _sending = false;

  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    // Simulate network send
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _sending = false;
        _submitted = true;
      });
      _checkCtrl.forward();
    }
  }

  void _resetAndGoHome() {
    widget.onReset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kBgPage,
        elevation: 0,
        leading: _submitted
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: kNavy),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          _submitted ? 'Report Sent' : 'Review & Submit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kNavy,
          ),
        ),
      ),
      body: _submitted
          ? _SuccessView(onReset: _resetAndGoHome, checkScale: _checkScale, disasterType: report.disasterType)
          : _ReviewView(
              report: report,
              now: now,
              sending: _sending,
              onSubmit: _submit,
            ),
    );
  }
}

// ─── Review View ──────────────────────────────────────────────────────────────
class _ReviewView extends StatelessWidget {
  final EmergencyReport report;
  final DateTime now;
  final bool sending;
  final VoidCallback onSubmit;

  const _ReviewView({
    required this.report,
    required this.now,
    required this.sending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Warning banner ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kRed.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: kRed, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Before Sending',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kRed,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Once submitted, this emergency report '
                        'will be broadcast to emergency services. '
                        'Please verify all information is accurate.',
                        style: TextStyle(
                          fontSize: 11,
                          color: kRed,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Report card ──────────────────────────────────────────────────
          _ReviewCard(
            title: 'Report Details',
            icon: Icons.report_rounded,
            color: const Color(0xFF2255CC),
            children: [
              _ReviewRow(
                label: 'Disaster Type',
                value: report.disasterType,
                valueColor: kRed,
              ),
              _ReviewRow(
                label: 'Severity',
                value: report.severity,
                valueColor: report.severity == 'Critical'
                    ? kRed
                    : (report.severity == 'Medium' ? kOrange : kGreen),
              ),
              _ReviewRow(
                label: 'Timestamp',
                value: DateFormat('dd MMM yyyy, hh:mm a').format(now),
              ),
              if (report.hasText)
                _ReviewRow(
                  label: 'Description',
                  value: report.textReport,
                  isMultiline: true,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Location card ────────────────────────────────────────────────
          _ReviewCard(
            title: 'Location',
            icon: Icons.location_on_rounded,
            color: kRed,
            children: [
              _ReviewRow(
                label: 'GPS Address',
                value: report.location ?? 'Not captured',
                valueColor: report.hasLocation ? kNavy : kTextMuted,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Attachments card ─────────────────────────────────────────────
          _ReviewCard(
            title: 'Attachments',
            icon: Icons.attach_file_rounded,
            color: kOrange,
            children: [
              _ReviewRow(
                label: 'Photos/Videos',
                value: report.hasMedia
                    ? '${report.mediaPaths.length} file(s) attached'
                    : 'None',
                icon: report.hasMedia
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                iconColor: report.hasMedia ? kGreen : kTextMuted,
              ),
              _ReviewRow(
                label: 'Voice Memo',
                value: report.hasVoice ? 'Recorded ✓' : 'None',
                icon: report.hasVoice
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                iconColor: report.hasVoice ? kGreen : kTextMuted,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Submit button ────────────────────────────────────────────────
          GestureDetector(
            onTap: sending ? null : onSubmit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: sending ? kRed.withOpacity(0.6) : kRed,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: sending
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'SUBMIT TO EMERGENCY SERVICES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final VoidCallback onReset;
  final Animation<double> checkScale;
  final String disasterType;

  const _SuccessView({
    required this.onReset,
    required this.checkScale,
    required this.disasterType,
  });

  String _getEmergencyNumber() {
    switch (disasterType) {
      case 'Flood': return '1070';
      case 'Fire': return '101';
      case 'Earthquake':
      case 'Cyclone':
      case 'Landslide': return '1078';
      case 'Medical Emergency':
      case 'Accident': return '108';
      default: return '112';
    }
  }

  String _getAuthorityName() {
    switch (disasterType) {
      case 'Flood': return 'State Relief (1070)';
      case 'Fire': return 'Fire Brigade (101)';
      case 'Earthquake':
      case 'Cyclone':
      case 'Landslide': return 'NDRF (1078)';
      case 'Medical Emergency':
      case 'Accident': return 'Ambulance (108)';
      default: return 'Emergency Helpline (112)';
    }
  }

  Future<void> _callAuthorities() async {
    final number = _getEmergencyNumber();
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: checkScale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: kGreen.withOpacity(0.3), width: 3),
                ),
                child: const Icon(Icons.check_rounded, color: kGreen, size: 52),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Report Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kNavy,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your emergency report has been broadcast '
              'to emergency services. Help is on the way.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextMid, height: 1.6),
            ),
            const SizedBox(height: 32),

            // Report ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number_rounded,
                    size: 16,
                    color: kTextMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Report ID: EM-${DateTime.now().millisecondsSinceEpoch % 100000}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: kNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Call Authorities
            GestureDetector(
              onTap: _callAuthorities,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kRed, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_rounded, color: kRed, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Call ${_getAuthorityName()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Go home
            GestureDetector(
              onTap: onReset,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Back to Home',
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
          ],
        ),
      ),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 15),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kNavy,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMultiline;
  final IconData? icon;
  final Color? iconColor;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isMultiline = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: kTextMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: valueColor ?? kNavy,
                    height: 1.5,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: kTextMuted),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: iconColor ?? kTextMuted),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
