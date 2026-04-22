// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/room_service_screen.dart';
import 'screens/wifi_info_screen.dart';
import 'screens/food_order_screen.dart';
import 'screens/qr_checkin_screen.dart';
import 'screens/emergency_sos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed (please run flutterfire configure): $e");
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final savedName = prefs.getString('userName') ?? '';
  runApp(StayEaseApp(isLoggedIn: isLoggedIn, savedName: savedName));
}

class StayEaseApp extends StatelessWidget {
  final bool isLoggedIn;
  final String savedName;
  const StayEaseApp(
      {super.key, required this.isLoggedIn, required this.savedName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayEase',
      debugShowCheckedModeBanner: false,
      theme: stayEaseTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) =>
            isLoggedIn ? HomeScreen(userName: savedName) : const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/roomservice': (context) => const RoomServiceScreen(),
        '/wifi': (context) => const WiFiInfoScreen(),
        '/food': (context) => const FoodOrderScreen(),
        '/qrcheckin': (context) => const QRCheckinScreen(),
        '/emergency': (context) => const EmergencySOSScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => HomeScreen(userName: args?['userName'] ?? ''),
          );
        }
        return null;
      },
    );
  }
}
