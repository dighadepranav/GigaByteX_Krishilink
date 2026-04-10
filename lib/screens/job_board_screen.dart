import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import '../utils/app_localizations.dart';
import 'landing_screen.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Mahesh Jadhav';
  String _userPhone = '9876543210';
  String _userLocation = 'Pune, Maharashtra';
  List<JobModel> _jobs = [];
  Set<String> _appliedJobIds = {};

  static const kPurple = Color(0xFF6A1B9A);
  static const kPurpleDark = Color(0xFF4A148C);
  static const kPurpleLight = Color(0xFF9C27B0);

  final List<JobModel> _demoJobs = [
    JobModel(
      id: 1,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      title: 'Harvesting Helper',
      description:
          'Need workers for tomato and chilli harvesting. Work for 6 hours daily. Immediate joining.',
      location: 'Pune, Maharashtra',
      wage: 350,
      duration: '5 days',
      workersNeeded: 10,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      applicationsCount: 3,
    ),
    JobModel(
      id: 2,
      farmerId: 2,
      farmerName: 'Suresh Yadav',
      title: 'Field Worker',
      description:
          'Looking for experienced farm workers for onion plantation. Accommodation available.',
      location: 'Nashik, Maharashtra',
      wage: 400,
      duration: '7 days',
      workersNeeded: 5,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      applicationsCount: 2,
    ),
    JobModel(
      id: 3,
      farmerId: 3,
      farmerName: 'Anita Deshmukh',
      title: 'Organic Farming Assistant',
      description:
          'Need help with organic vegetable farming. Knowledge of organic methods preferred.',
      location: 'Satara, Maharashtra',
      wage: 450,
      duration: '10 days',
      workersNeeded: 3,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      applicationsCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _jobs = List.from(_demoJobs);
  }

  Future<void> _applyForJob(String jobDocId) async {
    setState(() {
      _appliedJobIds.add(jobDocId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildJobsBody(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: kPurple,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.work_rounded),
                label: l10n?.translate('jobs') ?? 'Jobs'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: l10n?.translate('profile') ?? 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final appliedCount = _appliedJobIds.length;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPurple, kPurpleLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            children: [
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
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    '$appliedCount ${l10n?.translate('applied') ?? 'Applied'}',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _jobs.isEmpty
              ? Center(
                  child:
                      Text(l10n?.translate('no_jobs') ?? 'No jobs available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    final applied = _appliedJobIds.contains(job.docId);
                    return Container(
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
                        border: applied
                            ? Border.all(
                                color: kPurple.withOpacity(0.5), width: 1.5)
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(job.title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.green.shade200)),
                                  child: Text(job.formattedWage,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _chip(Icons.person_rounded, job.farmerName,
                                    Colors.blue),
                                _chip(Icons.location_on_rounded, job.location,
                                    Colors.orange),
                                _chip(Icons.access_time_rounded, job.duration,
                                    kPurple),
                                _chip(
                                    Icons.group_rounded,
                                    '${job.workersNeeded} ${l10n?.translate('workers_needed') ?? 'needed'}',
                                    Colors.teal),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(job.description,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600)),
                            const SizedBox(height: 14),
                            if (applied)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.green.shade300)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF2E7D32), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                        l10n?.translate(
                                                'application_submitted') ??
                                            'Application Submitted!',
                                        style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () => _applyForJob(job.docId),
                                  icon:
                                      const Icon(Icons.send_rounded, size: 16),
                                  label: Text(
                                      l10n?.translate('apply_now') ??
                                          'Apply Now',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: kPurple,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final appliedCount = _appliedJobIds.length;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
            child: Column(
              children: [
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
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(_userLocation,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.4))),
                    child: Text(
                        '👷  ${l10n?.translate('worker') ?? 'Farm Worker'}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
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
                  child: _miniStat(
                      '4.5 ⭐',
                      l10n?.translate('rating') ?? 'Rating',
                      Icons.star_rounded,
                      Colors.orange,
                      cardColor)),
            ],
          ),
          const SizedBox(height: 20),
          _profileTile(
              Icons.work_rounded,
              l10n?.translate('job_board') ?? 'Browse Jobs',
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
              Icons.edit_note_rounded,
              l10n?.translate('edit_profile') ?? 'Edit Profile',
              l10n?.translate('update_profile_desc') ??
                  'Update your name & details',
              Colors.blue.shade600,
              cardColor,
              _showEditProfile),
          _profileTile(
              Icons.help_outline_rounded,
              l10n?.translate('help_support') ?? 'Help & Support',
              'support@krishilink.com',
              Colors.teal,
              cardColor,
              () => _showInfo(
                  l10n?.translate('help_support') ?? 'Help & Support',
                  '📞 ${l10n?.translate('helpline') ?? 'Helpline'}: 1800-123-4567\n📧 ${l10n?.translate('email') ?? 'Email'}: support@krishilink.com')),
          _profileTile(
              Icons.info_outline_rounded,
              l10n?.translate('about_app') ?? 'About KrishiLink',
              '${l10n?.translate('version') ?? 'Version'} 1.0.0',
              Colors.grey.shade600,
              cardColor,
              () => _showInfo(
                  l10n?.translate('about_app') ?? 'About KrishiLink',
                  '🌾 KrishiLink connects farmers directly to buyers.\n\nVersion 1.0.0\n© 2024 KrishiLink')),
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
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LandingScreen()),
            (_) => false);
    }
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.translate('cancel') ?? 'Cancel')),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _userName = nameCtrl.text;
                _userLocation = locCtrl.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: kPurple, foregroundColor: Colors.white),
            child: Text(l10n?.translate('save') ?? 'Save'),
          ),
        ],
      ),
    );
  }
}
