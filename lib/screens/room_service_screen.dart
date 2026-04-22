import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomServiceScreen extends StatefulWidget {
  const RoomServiceScreen({super.key});

  @override
  State<RoomServiceScreen> createState() => _RoomServiceScreenState();
}

class _RoomServiceScreenState extends State<RoomServiceScreen> {
  final List<Map<String, dynamic>> _items = [
    {'label': 'Extra Towels', 'icon': Icons.dry_outlined, 'selected': false},
    {'label': 'Extra Pillow', 'icon': Icons.bed_outlined, 'selected': false},
    {'label': 'Blanket', 'icon': Icons.ac_unit_rounded, 'selected': false},
    {'label': 'Toiletries Kit', 'icon': Icons.soap_outlined, 'selected': false},
    {'label': 'Iron & Board', 'icon': Icons.iron_outlined, 'selected': false},
    {'label': 'Water Bottles', 'icon': Icons.water_drop_outlined, 'selected': false},
    {'label': 'Room Cleaning', 'icon': Icons.cleaning_services_outlined, 'selected': false},
    {'label': 'Do Not Disturb', 'icon': Icons.nights_stay_outlined, 'selected': false},
  ];

  final _otherController = TextEditingController();
  bool _otherExpanded = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        title: Text('Room Service',
            style: GoogleFonts.playfairDisplay(
                color: kNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kNavy),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  Text('SELECT ITEMS',
                      style: GoogleFonts.lato(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),

                  // Items grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final selected = item['selected'] as bool;
                      return GestureDetector(
                        onTap: () => setState(
                            () => _items[index]['selected'] = !selected),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected
                                ? kNavy
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? kGold
                                  : const Color(0xFFEEEEEE),
                              width: selected ? 1.8 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(item['icon'] as IconData,
                                  size: 30,
                                  color: selected
                                      ? kGold
                                      : kTeal),
                              const SizedBox(height: 8),
                              Text(item['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      color: selected
                                          ? Colors.white
                                          : kNavy,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                              if (selected) ...[
                                const SizedBox(height: 4),
                                const Icon(Icons.check_circle_rounded,
                                    color: kGold, size: 15),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── OTHER SECTION ──
                  Text('OTHER',
                      style: GoogleFonts.lato(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () =>
                        setState(() => _otherExpanded = !_otherExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _otherExpanded
                              ? kGold
                              : const Color(0xFFEEEEEE),
                          width: _otherExpanded ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_note_rounded,
                              color: kGold, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Write a custom request',
                              style: GoogleFonts.lato(
                                  color: kNavy,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ),
                        Icon(
                          _otherExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey[400],
                        ),
                      ]),
                    ),
                  ),

                  // Expandable text field
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Describe your request',
                              style: GoogleFonts.lato(
                                  color: Colors.grey[400],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _otherController,
                            maxLines: 4,
                            style: GoogleFonts.lato(
                                color: kNavy, fontSize: 14),
                            decoration: InputDecoration(
                              hintText:
                                  'e.g. Extra hangers, specific toiletry brand, etc.',
                              hintStyle: GoogleFonts.lato(
                                  color: Colors.grey[300], fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.all(14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEEEEEE)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: kGold, width: 1.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _otherExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Send Request button ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  final selected =
                      _items.where((i) => i['selected'] == true).toList();
                  final hasOther = _otherController.text.trim().isNotEmpty;
                  if (selected.isEmpty && !hasOther) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please select an item or write a request')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request sent! Staff will arrive shortly.',
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                      backgroundColor: kTeal,
                    ),
                  );
                  setState(() {
                    for (var i in _items) i['selected'] = false;
                    _otherController.clear();
                    _otherExpanded = false;
                  });
                },
                child: Text('Send Request',
                    style: GoogleFonts.lato(
                        color: kNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}