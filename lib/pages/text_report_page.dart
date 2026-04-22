import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../models/emergency_report.dart';











class TextReportPage extends StatefulWidget {
  final EmergencyReport report;
  const TextReportPage({super.key, required this.report});

  @override
  State<TextReportPage> createState() => _TextReportPageState();
}

class _TextReportPageState extends State<TextReportPage> {
  late TextEditingController _ctrl;
  String _disasterType = 'Other';
  String _severity = 'Medium';

  final List<String> _disasterTypes = [
    'Flood',
    'Fire',
    'Earthquake',
    'Cyclone',
    'Landslide',
    'Medical Emergency',
    'Accident',
    'Other',
  ];

  final List<Map<String, dynamic>> _severities = [
    {'label': 'Low', 'color': kGreen, 'icon': Icons.arrow_downward_rounded},
    {'label': 'Medium', 'color': kOrange, 'icon': Icons.remove_rounded},
    {'label': 'Critical', 'color': kRed, 'icon': Icons.arrow_upward_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.report.textReport);
    _disasterType = widget.report.disasterType;
    _severity = widget.report.severity;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.report.disasterType = _disasterType;
    widget.report.severity = _severity;
    widget.report.textReport = _ctrl.text.trim();
    Navigator.of(context).pop(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _ctrl.text.length;

    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        backgroundColor: kBgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Incident Report', style: GoogleFonts.playfairDisplay(color: kNavy, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
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
            // ── Disaster type ──────────────────────────────────────────────
            _Label(text: 'Disaster Type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _disasterTypes.map((type) {
                final selected = _disasterType == type;
                return GestureDetector(
                  onTap: () => setState(() => _disasterType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? kRed : kWhite,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? kRed : kBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : kNavy,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Severity ───────────────────────────────────────────────────
            _Label(text: 'Severity Level'),
            const SizedBox(height: 10),
            Row(
              children: _severities.map((s) {
                final selected = _severity == s['label'];
                final color = s['color'] as Color;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = s['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.12) : kWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : kBorder,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            s['icon'] as IconData,
                            color: selected ? color : kTextMuted,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected ? color : kTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Text report ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Label(text: 'Incident Description'),
                Text(
                  '$charCount / 1000',
                  style: const TextStyle(fontSize: 11, color: kTextMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: 10,
                maxLength: 1000,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13, color: kNavy, height: 1.5),
                decoration: const InputDecoration(
                  hintText:
                      'Describe what happened in detail…\n\n'
                      'Include:\n'
                      '• Number of people affected\n'
                      '• Current conditions\n'
                      '• Immediate needs\n'
                      '• Any hazards present',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: kTextMuted,
                    height: 1.6,
                  ),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Tips card ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFFF8F00),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Include number of people affected, '
                      'exact location details, and what immediate '
                      'help is needed.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5D4037),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Save button ────────────────────────────────────────────────
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: kRed,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withOpacity(0.35),
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
                      'Save Report',
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

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kNavy,
      ),
    );
  }
}
