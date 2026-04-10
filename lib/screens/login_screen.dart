import 'package:flutter/material.dart';
import 'farmer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;
  const LoginScreen({super.key, this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _selectedRole = 'farmer';

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole ?? 'farmer';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getRoleMeta() {
    return {
      'farmer': {
        'label': 'Farmer',
        'emoji': '👨‍🌾',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFF2E7D32),
        'hint': 'Manage your crops, list produce & track orders',
        'bgGrad': [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      },
      'buyer': {
        'label': 'Buyer',
        'emoji': '🛒',
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFF1565C0),
        'hint': 'Buy fresh produce directly from farms',
        'bgGrad': [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      },
      'worker': {
        'label': 'Farm Worker',
        'emoji': '👷',
        'icon': Icons.work_rounded,
        'color': const Color(0xFF6A1B9A),
        'hint': 'Find daily wage jobs at farms near you',
        'bgGrad': [const Color(0xFF4A148C), const Color(0xFF7B1FA2)],
      },
      'admin': {
        'label': 'Admin',
        'emoji': '🛡️',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFFC62828),
        'hint': 'Restricted access — admins only',
        'bgGrad': [const Color(0xFFB71C1C), const Color(0xFFE53935)],
      },
    };
  }

  void _handleLogin() {
    if (_selectedRole == 'farmer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FarmerDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleMeta = _getRoleMeta();
    final meta = roleMeta[_selectedRole]!;
    final roleColor = meta['color'] as Color;
    final roleGrad = meta['bgGrad'] as List<Color>;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: roleGrad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(meta['icon'] as IconData, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'KrishiLink',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${meta['emoji']}  ${meta['label']} Login',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    meta['hint'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Phone Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: '10-digit number',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      prefixText: '+91  ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: roleColor, width: 2),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roleColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Send OTP',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}