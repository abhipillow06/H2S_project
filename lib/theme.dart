// lib/theme.dart
// StayEase unified design tokens — used across all modules

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand palette ────────────────────────────────────────────────────────────
const kNavy        = Color(0xFF0A1628);
const kGold        = Color(0xFFFFD700);
const kGoldDark    = Color(0xFFB8860B);
const kBgPage      = Color(0xFFF7F8FA);
const kWhite       = Color(0xFFFFFFFF);
const kBorder      = Color(0xFFEEEEEE);
const kCardShadow  = Color(0x0A000000);

// Status colours
const kRed         = Color(0xFFCC2222);
const kRedLight    = Color(0xFFFFEEEE);
const kOrange      = Color(0xFFE07020);
const kGreen       = Color(0xFF2A7D4F);
const kBlue        = Color(0xFF1565C0);
const kPurple      = Color(0xFF7B1FA2);
const kTeal        = Color(0xFF00897B);

// Text
const kTextDark    = Color(0xFF0A1628);
const kTextMid     = Color(0xFF888888);
const kTextMuted   = Color(0xFF999999);
const kTextLight   = Color(0xFFBBBBBB);

// ── ThemeData ────────────────────────────────────────────────────────────────
ThemeData stayEaseTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: kGold),
  textTheme: GoogleFonts.latoTextTheme(),
  scaffoldBackgroundColor: kBgPage,
  appBarTheme: const AppBarTheme(
    backgroundColor: kWhite,
    foregroundColor: kNavy,
    elevation: 0,
    centerTitle: false,
  ),
  useMaterial3: true,
);

// ── Shared AppBar builder ────────────────────────────────────────────────────
AppBar stayEaseAppBar({
  required String title,
  bool showBrand = false,
  List<Widget>? actions,
  Widget? leading,
}) {
  return AppBar(
    backgroundColor: kWhite,
    elevation: 0,
    leading: leading,
    automaticallyImplyLeading: leading == null ? true : false,
    title: showBrand
        ? _BrandTitle(label: title)
        : Text(
            title,
            style: GoogleFonts.playfairDisplay(
              color: kNavy,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
    iconTheme: const IconThemeData(color: kNavy),
    actions: actions,
  );
}

class _BrandTitle extends StatelessWidget {
  final String label;
  const _BrandTitle({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
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
      Text(label,
          style: GoogleFonts.playfairDisplay(
              color: kNavy, fontWeight: FontWeight.bold, fontSize: 20)),
    ]);
  }
}

// ── Shared card decoration ───────────────────────────────────────────────────
BoxDecoration cardDecoration({
  Color? color,
  double radius = 18,
  bool bordered = true,
}) =>
    BoxDecoration(
      color: color ?? kWhite,
      borderRadius: BorderRadius.circular(radius),
      border: bordered ? Border.all(color: kBorder) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    );

// ── Gold primary button ──────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  const GoldButton({super.key, required this.label, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: kNavy, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: GoogleFonts.lato(
                    color: kNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.lato(
                color: kTextMid,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1)),
      );
}
