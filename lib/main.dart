import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KrishiLinkApp());
}

class KrishiLinkApp extends StatelessWidget {
  const KrishiLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrishiLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F0),
      ),
      home: const SplashScreen(),
    );
  }
}