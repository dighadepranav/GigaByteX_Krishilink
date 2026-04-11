import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_localizations.dart';
import 'landing_screen.dart';
import 'farmer_dashboard.dart';
import 'buyer_dashboard.dart';
import 'job_board_screen.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('userRole') ?? '';

    if (!isLoggedIn || role.isEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LandingScreen()));
      return;
    }

    Widget dest;
    switch (role) {
      case 'farmer':
        dest = const FarmerDashboard();
        break;
      case 'buyer':
        dest = const BuyerDashboard();
        break;
      case 'worker':
        dest = const JobBoardScreen();
        break;
      case 'admin':
        dest = const AdminDashboard();
        break;
      default:
        dest = const LandingScreen();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade400],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.agriculture,
                    size: 80, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 30),
              Text(l10n?.translate('app_name') ?? 'KrishiLink',
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(
                  l10n?.translate('empowering_rural_india') ??
                      'Empowering Rural India',
                  style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
