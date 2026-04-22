import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class WiFiInfoScreen extends StatelessWidget {
  const WiFiInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('WiFi Access',
            style: GoogleFonts.playfairDisplay(
                color: kNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kNavy),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPurple.withOpacity(0.07),
              ),
              child: const Icon(Icons.wifi_rounded,
                  color: kPurple, size: 52),
            ),
            const SizedBox(height: 24),

            Text('Hotel WiFi',
                style: GoogleFonts.playfairDisplay(
                    color: kNavy,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to view your\nWiFi credentials for this stay.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: Colors.grey[400], fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 48),

            // ── WiFi Details Button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.wifi_password_rounded,
                    color: Colors.white, size: 20),
                label: Text('View WiFi Details',
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                onPressed: () {
                  // Your teammate can connect this to the backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WiFi details will appear here'),
                      backgroundColor: kPurple,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Text('Complimentary WiFi for all guests',
                style: GoogleFonts.lato(
                    color: Colors.grey[300], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}