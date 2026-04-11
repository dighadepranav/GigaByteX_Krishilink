// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../utils/locale_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_switcher.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context);

    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Remove back button
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: iconColor,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: iconColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
          const LanguageSwitcher(),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.agriculture,
                      size: 50, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 12),
                Text(l10n?.translate('app_name') ?? 'KrishiLink',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  l10n?.translate('tagline') ??
                      'Transparent Agri Supply Chain\n& Rural Livelihood Platform',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ]),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n?.translate('choose_role') ?? 'Choose your role',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(children: [
                _roleCard(
                    context,
                    l10n?.translate('farmer') ?? 'Farmer',
                    l10n?.translate('sell_produce') ??
                        'Sell produce directly to buyers',
                    Icons.agriculture,
                    const Color(0xFF2E7D32),
                    'farmer'),
                const SizedBox(height: 10),
                _roleCard(
                    context,
                    l10n?.translate('buyer') ?? 'Buyer',
                    l10n?.translate('buy_fresh') ??
                        'Buy fresh produce from farms',
                    Icons.shopping_cart_rounded,
                    Colors.blue.shade700,
                    'buyer'),
                const SizedBox(height: 10),
                _roleCard(
                    context,
                    l10n?.translate('worker') ?? 'Worker',
                    l10n?.translate('find_work') ??
                        'Get daily wage jobs on farms',
                    Icons.work_rounded,
                    Colors.purple.shade600,
                    'worker'),
                const SizedBox(height: 10),
                _roleCard(
                    context,
                    l10n?.translate('admin') ?? 'Admin',
                    l10n?.translate('admin_panel') ??
                        'Platform management & analytics',
                    Icons.admin_panel_settings_rounded,
                    Colors.red.shade700,
                    'admin'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, String role) {
    return Expanded(
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LoginScreen(selectedRole: role))),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ]),
          ),
        ),
      ),
    );
  }
}
