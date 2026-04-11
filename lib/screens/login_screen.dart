import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_button.dart';
import '../utils/app_localizations.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import 'farmer_dashboard.dart';
import 'buyer_dashboard.dart';
import 'job_board_screen.dart';
import 'admin_dashboard.dart';
import 'landing_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? selectedRole;

  const LoginScreen({super.key, this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _adminUserCtrl = TextEditingController();
  final _adminPassCtrl = TextEditingController();

  String _selectedRole = 'farmer';
  bool _isOtpSent = false;
  bool _isLocationStep = false;
  bool _isLoading = false;
  bool _obscurePass = true;
  String _selectedLocation = '';
  String _verificationId = '';

  final _authService = FirebaseAuthService();
  final _firestoreService = FirestoreService();

  static const _indianLocations = [
    'Mumbai, Maharashtra',
    'Pune, Maharashtra',
    'Nashik, Maharashtra',
    'Nagpur, Maharashtra',
    'Aurangabad, Maharashtra',
    'Kolhapur, Maharashtra',
    'Satara, Maharashtra',
    'Solapur, Maharashtra',
    'Delhi, NCR',
    'Lucknow, Uttar Pradesh',
    'Varanasi, Uttar Pradesh',
    'Agra, Uttar Pradesh',
    'Jaipur, Rajasthan',
    'Jodhpur, Rajasthan',
    'Ahmedabad, Gujarat',
    'Surat, Gujarat',
    'Vadodara, Gujarat',
    'Bhopal, Madhya Pradesh',
    'Indore, Madhya Pradesh',
    'Patna, Bihar',
    'Gaya, Bihar',
    'Ranchi, Jharkhand',
    'Bhubaneswar, Odisha',
    'Chennai, Tamil Nadu',
    'Coimbatore, Tamil Nadu',
    'Bengaluru, Karnataka',
    'Mysuru, Karnataka',
    'Hyderabad, Telangana',
    'Vijayawada, Andhra Pradesh',
    'Kolkata, West Bengal',
    'Chandigarh, Punjab',
    'Ludhiana, Punjab',
    'Amritsar, Punjab',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole ?? 'farmer';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getRoleMeta(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return {
      'farmer': {
        'label': l10n?.translate('farmer') ?? 'Farmer',
        'emoji': '👨‍🌾',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFF2E7D32),
        'hint': 'Manage your crops, list produce & track orders',
        'bgGrad': [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
      },
      'buyer': {
        'label': l10n?.translate('buyer') ?? 'Buyer',
        'emoji': '🛒',
        'icon': Icons.shopping_cart_rounded,
        'color': const Color(0xFF1565C0),
        'hint': 'Buy fresh produce directly from farms',
        'bgGrad': [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
      },
      'worker': {
        'label': l10n?.translate('worker') ?? 'Farm Worker',
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

  // ── Admin Login ──────────────────────────────────────────────────────────
  Future<void> _adminLogin() async {
    final l10n = AppLocalizations.of(context);
    if (_adminUserCtrl.text.trim() != 'admin' ||
        _adminPassCtrl.text.trim() != 'admin') {
      _snack(
          l10n?.translate('invalid_admin_credentials') ??
              'Invalid credentials. Use admin / admin',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', 'admin');
    await prefs.setString('userName', 'Admin');
    await prefs.setString('userUid', 'admin_uid');
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
  }

  // ── Send OTP ─────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _snack(
          l10n?.translate('invalid_phone') ??
              'Enter a valid 10-digit phone number',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);
    await _authService.sendOtp(
      phone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          _isLoading = false;
        });
        _snack(l10n?.translate('otp_sent_sms') ?? 'OTP sent! Check your SMS.');
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _snack(error, isError: true);
      },
    );
  }

  // ── Verify OTP ───────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context);
    if (_otpController.text.trim().length < 6) {
      _snack(l10n?.translate('enter_6_digit_otp') ?? 'Enter the 6-digit OTP',
          isError: true);
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _snack(
          l10n?.translate('please_enter_full_name') ??
              'Please enter your full name',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _authService.verifyOtp(
        verificationId: _verificationId,
        otp: _otpController.text.trim(),
        role: _selectedRole,
        name: _nameController.text.trim(),
      );
      if (user != null) {
        final firebaseUser = FirebaseAuth.instance.currentUser!;
        final prefs = await SharedPreferences.getInstance();
        // FIX: Store uid_role as the key so Firestore lookups match
        // the uid_role document created in firebase_auth_service.dart.
        // This allows the same phone number to have separate profiles
        // per role (farmer, buyer, worker).
        await prefs.setString('userUid', '${firebaseUser.uid}_${user.role}');
        await prefs.setInt('userId', user.id);
        await prefs.setString('userPhone', user.phone);
        await prefs.setString('userName', user.name);
        await prefs.setString('userRole', user.role);
        await prefs.setBool('isLoggedIn', true);
        if (!mounted) return;
        setState(() => _isLocationStep = true);
      }
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyAuthError(e), isError: true);
    } catch (e) {
      _snack('Login failed: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Complete login after location selection ───────────────────────────────
  Future<void> _completeLogin() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedLocation.isEmpty) {
      _snack(
          l10n?.translate('please_select_location') ??
              'Please select your location',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userLocation', _selectedLocation);

    // Update location in Firestore too
    final uid = prefs.getString('userUid') ?? '';
    if (uid.isNotEmpty && uid != 'admin_uid') {
      await _firestoreService.updateUserLocation(uid, _selectedLocation);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    Widget dash;
    switch (_selectedRole) {
      case 'farmer':
        dash = const FarmerDashboard();
        break;
      case 'buyer':
        dash = const BuyerDashboard();
        break;
      default:
        dash = const JobBoardScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dash));
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: Duration(seconds: isError ? 4 : 2),
    ));
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Wrong OTP. Please check the SMS.';
      case 'session-expired':
        return 'OTP expired. Tap "Send OTP" again.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roleMeta = _getRoleMeta(context);
    final meta = roleMeta[_selectedRole]!;
    final isAdmin = _selectedRole == 'admin';
    final roleColor = meta['color'] as Color;
    final roleGrad = meta['bgGrad'] as List<Color>;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Hero Header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: roleGrad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LandingScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: Icon(meta['icon'] as IconData,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(l10n?.translate('app_name') ?? 'KrishiLink',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${meta['emoji']}  ${meta['label']} Login',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(height: 10),
              Text(meta['hint'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAdmin) ...[
                  Text(
                      l10n?.translate('admin_credentials') ??
                          'Admin Credentials',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: roleColor)),
                  const SizedBox(height: 16),
                  _field(_adminUserCtrl, 'Username', Icons.person_rounded,
                      roleColor),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _adminPassCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: l10n?.translate('password') ?? 'Password',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: roleColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: l10n?.translate('login_as_admin') ?? 'Login as Admin',
                    onPressed: _adminLogin,
                    isLoading: _isLoading,
                    backgroundColor: roleColor,
                    icon: Icons.admin_panel_settings_rounded,
                  ),
                ] else if (_isLocationStep) ...[
                  Text(
                      l10n?.translate('select_your_location') ??
                          'Select Your Location',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: roleColor)),
                  const SizedBox(height: 6),
                  Text(
                    'Helps connect you with nearby '
                    '${_selectedRole == 'farmer' ? 'buyers' : _selectedRole == 'buyer' ? 'farmers' : 'farm jobs'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _selectedLocation.isEmpty
                              ? Colors.grey.shade400
                              : roleColor,
                          width: _selectedLocation.isEmpty ? 1 : 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value:
                          _selectedLocation.isEmpty ? null : _selectedLocation,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: Row(children: [
                        Icon(Icons.location_on_rounded,
                            color: Colors.grey.shade500, size: 20),
                        const SizedBox(width: 8),
                        Text(
                            l10n?.translate('select_city_district') ??
                                'Select your city / district',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14)),
                      ]),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: roleColor),
                      items: _indianLocations
                          .map((loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedLocation = val ?? ''),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: l10n?.translate('continue_to_dashboard') ??
                        'Continue to Dashboard',
                    onPressed: _completeLogin,
                    isLoading: _isLoading,
                    backgroundColor: roleColor,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => setState(() => _isLocationStep = false),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text(l10n?.translate('go_back') ?? 'Go Back'),
                    style: TextButton.styleFrom(foregroundColor: roleColor),
                  ),
                ] else ...[
                  Text(_isOtpSent ? 'Verify Your Number' : 'Enter Phone Number',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: roleColor)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isOtpSent,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText:
                          l10n?.translate('phone_number') ?? 'Mobile Number',
                      hintText: l10n?.translate('ten_digit_number') ??
                          '10-digit number',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      prefixText: '+91  ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: roleColor, width: 2),
                      ),
                      counterText: '',
                      suffixIcon: _isOtpSent
                          ? TextButton(
                              onPressed: () =>
                                  setState(() => _isOtpSent = false),
                              child: Text(l10n?.translate('change') ?? 'Change',
                                  style: TextStyle(fontSize: 12)))
                          : null,
                    ),
                  ),
                  if (_isOtpSent) ...[
                    const SizedBox(height: 14),
                    _field(_nameController, 'Full Name', Icons.person_rounded,
                        roleColor),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: l10n?.translate('enter_otp') ?? 'OTP',
                        hintText: l10n?.translate('otp_sms_hint') ??
                            '6-digit OTP from SMS',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: roleColor, width: 2),
                        ),
                        counterText: '',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isOtpSent
                        ? (l10n?.translate('verify_continue') ??
                            'Verify and Continue')
                        : (l10n?.translate('send_otp') ?? 'Send OTP'),
                    onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                    isLoading: _isLoading,
                    backgroundColor: roleColor,
                    icon: _isOtpSent
                        ? Icons.arrow_forward_rounded
                        : Icons.send_rounded,
                  ),
                  const SizedBox(height: 16),
                  _roleInfoCard(meta, roleColor),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      Color roleColor) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: roleColor, width: 2),
        ),
      ),
    );
  }

  Widget _roleInfoCard(Map<String, dynamic> meta, Color roleColor) {
    final features = _roleFeatures(_selectedRole);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: roleColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${meta['label']} Features',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: roleColor, fontSize: 13)),
          const SizedBox(height: 6),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Icon(Icons.check_circle_outline, size: 14, color: roleColor),
                  const SizedBox(width: 6),
                  Text(f,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ]),
              )),
        ],
      ),
    );
  }

  List<String> _roleFeatures(String role) {
    switch (role) {
      case 'farmer':
        return [
          'List & manage your crops',
          'Set your own prices',
          'Receive & manage orders',
          'Post farm job openings',
        ];
      case 'buyer':
        return [
          'Browse fresh produce',
          'Buy directly from farmers',
          'Track your orders live',
          'No middlemen — better prices',
        ];
      case 'worker':
        return [
          'Browse farm jobs near you',
          'Apply with one tap',
          'View wages before applying',
          'Flexible duration jobs',
        ];
      default:
        return [];
    }
  }
}
