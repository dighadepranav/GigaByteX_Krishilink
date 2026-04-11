// lib/screens/job_board_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/job_model.dart';
import '../utils/app_localizations.dart';
import '../utils/theme_provider.dart';
import '../utils/locale_provider.dart';
import 'landing_screen.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Worker';
  String _userPhone = '';
  String _userLocation = 'Pune, Maharashtra';
  String _userUid = '';
  bool _isLoggedInAsWorker = false;
  List<JobModel> _jobs = [];
  Map<String, String> _applicationStatuses = {};

  StreamSubscription? _jobsSub;
  StreamSubscription? _appsSub;

  static const kPurple = Color(0xFF6A1B9A);
  static const kPurpleDark = Color(0xFF4A148C);
  static const kPurpleLight = Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Worker';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userLocation = prefs.getString('userLocation') ?? 'Pune, Maharashtra';
      _userUid = prefs.getString('userUid') ?? '';
      _isLoggedInAsWorker = (prefs.getString('userRole') == 'worker') &&
          (prefs.getBool('isLoggedIn') ?? false);
    });
    _listenToJobs();
    if (_userUid.isNotEmpty) _listenToApplications();
  }

  void _listenToJobs() {
    _jobsSub?.cancel();
    _jobsSub = FirestoreService().streamOpenJobs().listen((jobs) {
      if (mounted) {
        final markedJobs = jobs.map((job) {
          final status = _applicationStatuses[job.docId];
          return job.copyWith(
            isApplied: status != null,
          );
        }).toList();
        setState(() => _jobs = markedJobs);
      }
    });
  }

  void _listenToApplications() {
    _appsSub?.cancel();
    _appsSub = FirestoreService()
        .streamUserApplicationsWithStatus(_userUid)
        .listen((statusMap) {
      _applicationStatuses = statusMap;
      final updatedJobs = _jobs.map((job) {
        final status = _applicationStatuses[job.docId];
        return job.copyWith(
          isApplied: status != null,
        );
      }).toList();
      if (mounted) setState(() => _jobs = updatedJobs);
    });
  }

  Future<void> _applyForJob(String jobDocId) async {
    final l10n = AppLocalizations.of(context);
    try {
      await FirestoreService().applyForJob(
        jobDocId: jobDocId,
        workerUid: _userUid,
        workerName: _userName,
        workerPhone: _userPhone,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n?.translate('application_submitted') ??
              'Application submitted! Farmer will review.'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n?.translate('error_prefix') ?? 'Error'}: $e'),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LandingScreen()), (_) => false);
  }

  @override
  void dispose() {
    _jobsSub?.cancel();
    _appsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showTabs = _isLoggedInAsWorker;
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l10n?.translate('exit_app') ?? 'Exit App'),
            content: Text(l10n?.translate('exit_confirm') ??
                'Do you want to exit KrishiLink?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n?.translate('cancel') ?? 'Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(l10n?.translate('confirm') ?? 'Exit')),
            ],
          ),
        );
        return confirm == true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n?.translate('job_board') ?? 'Rural Job Board',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: kPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: !_isLoggedInAsWorker,
        ),
        body: showTabs
            ? IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildJobsBody(),
                  _buildProfileTab(),
                ],
              )
            : _buildJobsBody(),
        bottomNavigationBar: showTabs
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
                selectedItemColor: kPurple,
                unselectedItemColor: Colors.grey.shade500,
                backgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.work_rounded),
                      label: l10n?.translate('jobs') ?? 'Jobs'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.person_rounded),
                      label: l10n?.translate('profile') ?? 'Profile'),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildJobsBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (_isLoggedInAsWorker)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [kPurple, kPurpleLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Text('👷', style: TextStyle(fontSize: 24))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${l10n?.translate('hello') ?? 'Hello'}, $_userName!',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(
                        _userPhone.isNotEmpty
                            ? _userPhone
                            : (l10n?.translate('worker') ?? 'Farm Worker'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      '${_applicationStatuses.length} ${l10n?.translate('applied') ?? 'Applied'}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12))),
            ]),
          ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                sliver: _jobs.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                            child: Text(l10n?.translate('no_jobs') ??
                                'No jobs available')))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final job = _jobs[index];
                            final appliedStatus =
                                _applicationStatuses[job.docId];
                            final isApplied = appliedStatus != null;
                            final isAccepted = appliedStatus == 'accepted';
                            final isRejected = appliedStatus == 'rejected';

                            String statusMessage = '';
                            if (isAccepted) {
                              statusMessage =
                                  l10n?.translate('accepted_contact_soon') ??
                                      'Accepted - Farmer will contact you soon';
                            } else if (isRejected) {
                              statusMessage =
                                  l10n?.translate('rejected_try_other_jobs') ??
                                      'Rejected - Try other jobs';
                            } else if (appliedStatus == 'pending') {
                              statusMessage =
                                  l10n?.translate('application_under_review') ??
                                      'Application under review';
                            }

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                                border: isApplied
                                    ? Border.all(
                                        color: Colors.purple.shade300,
                                        width: 1.5)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(job.title,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: Colors
                                                            .green.shade200)),
                                                child: Text('₹${job.wage}/day',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF2E7D32),
                                                        fontSize: 13))),
                                          ]),
                                      const SizedBox(height: 10),
                                      Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          children: [
                                            _chip(Icons.person_rounded,
                                                job.farmerName, Colors.blue),
                                            _chip(Icons.location_on_rounded,
                                                job.location, Colors.orange),
                                            _chip(Icons.access_time_rounded,
                                                job.duration, Colors.purple),
                                            _chip(
                                                Icons.group_rounded,
                                                '${job.workersNeeded} ${l10n?.translate('workers_needed') ?? 'workers needed'}',
                                                Colors.teal),
                                          ]),
                                      const SizedBox(height: 14),
                                      if (isApplied)
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                                color: isAccepted
                                                    ? Colors.green.shade50
                                                    : isRejected
                                                        ? Colors.red.shade50
                                                        : Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: isAccepted
                                                        ? Colors.green.shade300
                                                        : isRejected
                                                            ? Colors
                                                                .red.shade300
                                                            : Colors.orange
                                                                .shade300)),
                                            child: Row(children: [
                                              Icon(
                                                  isAccepted
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : isRejected
                                                          ? Icons.cancel_rounded
                                                          : Icons
                                                              .hourglass_empty_rounded,
                                                  color: isAccepted
                                                      ? Colors.green
                                                      : isRejected
                                                          ? Colors.red
                                                          : Colors.orange,
                                                  size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  statusMessage,
                                                  style: TextStyle(
                                                      color: isAccepted
                                                          ? Colors
                                                              .green.shade800
                                                          : isRejected
                                                              ? Colors
                                                                  .red.shade800
                                                              : Colors.orange
                                                                  .shade800,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ]))
                                      else
                                        SizedBox(
                                            width: double.infinity,
                                            height: 44,
                                            child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _applyForJob(job.docId),
                                                icon: const Icon(
                                                    Icons.send_rounded,
                                                    size: 16),
                                                label: Text(
                                                    l10n?.translate('apply_now') ??
                                                        'Apply Now',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: kPurple,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10))))),
                                    ]),
                              ),
                            );
                          },
                          childCount: _jobs.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final appliedCount = _applicationStatuses.length;
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPurpleDark, kPurpleLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: kPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text('👷', style: TextStyle(fontSize: 38)))),
            const SizedBox(height: 12),
            Text(_userName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            if (_userPhone.isNotEmpty)
              Text(_userPhone,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(_userLocation,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4))),
                child: Text('👷  ${l10n?.translate('worker') ?? 'Farm Worker'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _miniStat(
                  '${_jobs.length}',
                  l10n?.translate('available') ?? 'Available',
                  Icons.work_rounded,
                  kPurple,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat(
                  '$appliedCount',
                  l10n?.translate('applied') ?? 'Applied',
                  Icons.check_circle_rounded,
                  Colors.green,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat('4.5 ⭐', l10n?.translate('rating') ?? 'Rating',
                  Icons.star_rounded, Colors.orange, cardColor)),
        ]),
        const SizedBox(height: 20),
        _profileTile(
            Icons.work_rounded,
            l10n?.translate('browse_jobs') ?? 'Browse Jobs',
            '${_jobs.length} ${l10n?.translate('available') ?? 'available'}',
            kPurple,
            cardColor,
            () => setState(() => _selectedIndex = 0)),
        _profileTile(
            Icons.check_circle_rounded,
            l10n?.translate('applied_jobs') ?? 'Applied Jobs',
            '$appliedCount ${l10n?.translate('applied') ?? 'applied'}',
            Colors.green,
            cardColor,
            () => setState(() => _selectedIndex = 0)),
        _profileTile(
            Icons.brightness_6_rounded,
            l10n?.translate('dark_mode') ?? 'Dark Mode',
            themeProvider.isDarkMode
                ? (l10n?.translate('enabled') ?? 'Enabled')
                : (l10n?.translate('disabled') ?? 'Disabled'),
            Colors.purple,
            cardColor,
            () => themeProvider.toggleTheme()),
        _profileTile(
            Icons.language_rounded,
            l10n?.translate('language') ?? 'Language',
            localeProvider.locale.languageCode == 'en'
                ? 'English'
                : (localeProvider.locale.languageCode == 'hi'
                    ? 'हिंदी'
                    : 'मराठी'),
            Colors.teal,
            cardColor,
            () => _showLanguageDialog()),
        _profileTile(
            Icons.edit_note_rounded,
            l10n?.translate('edit_profile') ?? 'Edit Profile',
            l10n?.translate('update_profile_desc') ??
                'Update your name and details',
            Colors.blue.shade600,
            cardColor,
            _showEditProfile),
        _profileTile(
            Icons.help_outline_rounded,
            l10n?.translate('help_support') ?? 'Help & Support',
            'support@krishilink.com',
            Colors.teal,
            cardColor,
            () => _showInfo(l10n?.translate('help_support') ?? 'Help & Support',
                '📞 ${l10n?.translate('helpline') ?? 'Helpline'}: 1800-123-4567\n📧 ${l10n?.translate('email') ?? 'Email'}: support@krishilink.com\n\nAvailable Mon–Sat, 8 AM – 8 PM')),
        _profileTile(
            Icons.info_outline_rounded,
            l10n?.translate('about_app') ?? 'About KrishiLink',
            '${l10n?.translate('version') ?? 'Version'} 1.0.0',
            Colors.grey.shade600,
            cardColor,
            () => _showInfo(l10n?.translate('about_app') ?? 'About KrishiLink',
                '🌾 KrishiLink connects farmers directly to buyers, eliminating middlemen and ensuring fair prices.\n\nVersion 1.0.0\n© 2024 KrishiLink')),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(l10n?.translate('logout') ?? 'Logout',
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 20),
      ]),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n?.translate('language') ?? 'Select Language'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(l10n?.translate('english') ?? 'English'),
            onTap: () async {
              await localeProvider.setLocale('en');
              if (mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(l10n?.translate('hindi') ?? 'Hindi'),
            onTap: () async {
              await localeProvider.setLocale('hi');
              if (mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(l10n?.translate('marathi') ?? 'Marathi'),
            onTap: () async {
              await localeProvider.setLocale('mr');
              if (mounted) Navigator.pop(context);
            },
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.translate('close') ?? 'Close')),
        ],
      ),
    );
  }

  Widget _miniStat(
      String val, String label, IconData icon, Color color, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ]),
    );
  }

  Widget _profileTile(IconData icon, String title, String sub, Color color,
      Color cardColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)
          ]),
      child: ListTile(
        onTap: onTap,
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing:
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _confirmLogout() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.logout_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Text(l10n?.translate('logout') ?? 'Logout')
        ]),
        content: Text(l10n?.translate('logout_confirm') ??
            'Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.translate('cancel') ?? 'Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text(l10n?.translate('logout') ?? 'Logout')),
        ],
      ),
    );
    if (confirm == true) _logout();
  }

  void _showInfo(String title, String content) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple, foregroundColor: Colors.white),
              child: Text(l10n?.translate('close') ?? 'Close'))
        ],
      ),
    );
  }

  void _showEditProfile() {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: _userName);
    final locCtrl = TextEditingController(text: _userLocation);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n?.translate('edit_profile') ?? 'Edit Profile',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                  labelText: l10n?.translate('your_name') ?? 'Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          TextField(
              controller: locCtrl,
              decoration: InputDecoration(
                  labelText: l10n?.translate('location') ?? 'Location',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.translate('cancel') ?? 'Cancel')),
          ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userName', nameCtrl.text);
                await prefs.setString('userLocation', locCtrl.text);
                setState(() {
                  _userName = nameCtrl.text;
                  _userLocation = locCtrl.text;
                });
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple, foregroundColor: Colors.white),
              child: Text(l10n?.translate('save') ?? 'Save')),
        ],
      ),
    );
  }
}
