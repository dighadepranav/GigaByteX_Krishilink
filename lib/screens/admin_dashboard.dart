// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/theme_provider.dart';
import '../utils/locale_provider.dart';
import '../utils/app_localizations.dart';
import 'landing_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  Map<String, dynamic> _stats = {};
  List<UserModel> _allUsers = [];
  String _userFilter = 'all';
  bool _isLoadingUsers = false;

  static const kRed = Color(0xFFC62828);
  static const kRedDark = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUsers();
  }

  Future<void> _loadStats() async {
    final stats = await FirestoreService().getAdminStats();
    if (mounted) setState(() => _stats = stats);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    final users = await FirestoreService().getAllUsers();
    if (mounted)
      setState(() {
        _allUsers = users;
        _isLoadingUsers = false;
      });
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'farmer':
        return const Color(0xFF2E7D32);
      case 'buyer':
        return const Color(0xFF1565C0);
      case 'worker':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'farmer':
        return Icons.agriculture;
      case 'buyer':
        return Icons.shopping_cart;
      case 'worker':
        return Icons.work;
      default:
        return Icons.person;
    }
  }

  Widget _filterChip(String label, String filterValue, int count) {
    final isSelected = _userFilter == filterValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _userFilter = selected ? filterValue : 'all';
        });
      },
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      selectedColor: kRed.withOpacity(0.2),
      checkmarkColor: kRed,
      labelStyle: TextStyle(
          color: isSelected ? kRed : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(l10n?.translate('krishilink_admin') ?? 'KrishiLink Admin',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
        backgroundColor: kRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {})
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildReportsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kRed,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: l10n?.translate('overview') ?? 'Overview'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.people_rounded),
              label: l10n?.translate('users') ?? 'Users'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              label: l10n?.translate('reports') ?? 'Reports'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: l10n?.translate('profile') ?? 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kRedDark, kRed]),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.admin_panel_settings, size: 35, color: kRed)),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        l10n?.translate('admin_dashboard') ?? 'Admin Dashboard',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text(
                        l10n?.translate('platform_performance_overview') ??
                            'Platform Performance Overview',
                        style: TextStyle(color: Colors.white70)),
                  ])),
            ]),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildStatCard(
                  'Total Farmers',
                  _stats['farmers']?.toString() ?? '0',
                  Icons.agriculture,
                  Colors.orange,
                  cardColor),
              _buildStatCard(
                  'Total Buyers',
                  _stats['buyers']?.toString() ?? '0',
                  Icons.shopping_cart,
                  Colors.blue,
                  cardColor),
              _buildStatCard(
                  'Active Workers',
                  _stats['workers']?.toString() ?? '0',
                  Icons.work,
                  Colors.purple,
                  cardColor),
              _buildStatCard(
                  'Total Orders',
                  _stats['orders']?.toString() ?? '0',
                  Icons.shopping_bag,
                  Colors.green,
                  cardColor),
              _buildStatCard(
                  'Revenue',
                  '₹${((_stats['total_value'] ?? 0) / 100000).toStringAsFixed(1)}L',
                  Icons.currency_rupee,
                  Colors.teal,
                  cardColor),
              _buildStatCard(
                  'Open Jobs',
                  _stats['open_jobs']?.toString() ?? '0',
                  Icons.work_outline,
                  Colors.indigo,
                  cardColor),
            ],
          ),
          const SizedBox(height: 24),
          Text(
              l10n?.translate('weekly_revenue_trend') ?? 'Weekly Revenue Trend',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 15000),
                        FlSpot(1, 23000),
                        FlSpot(2, 18000),
                        FlSpot(3, 32000),
                        FlSpot(4, 28000),
                        FlSpot(5, 41000),
                        FlSpot(6, 35000)
                      ],
                      isCurved: true,
                      color: kRed,
                      barWidth: 3,
                      belowBarData:
                          BarAreaData(show: true, color: kRed.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    final filteredUsers = _allUsers.where((u) {
      if (_userFilter == 'all') return true;
      return u.role == _userFilter;
    }).toList();

    final farmerCount = _allUsers.where((u) => u.role == 'farmer').length;
    final buyerCount = _allUsers.where((u) => u.role == 'buyer').length;
    final workerCount = _allUsers.where((u) => u.role == 'worker').length;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _filterChip('All', 'all', farmerCount + buyerCount + workerCount),
              const SizedBox(width: 8),
              _filterChip('Farmers', 'farmer', farmerCount),
              const SizedBox(width: 8),
              _filterChip('Buyers', 'buyer', buyerCount),
              const SizedBox(width: 8),
              _filterChip('Workers', 'worker', workerCount),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : filteredUsers.isEmpty
                  ? Center(
                      child: Text(l10n?.translate('no_users_found') ??
                          'No users found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredUsers.length,
                      itemBuilder: (ctx, idx) {
                        final user = filteredUsers[idx];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _roleColor(user.role).withOpacity(0.2),
                              child: Icon(_roleIcon(user.role),
                                  color: _roleColor(user.role)),
                            ),
                            title: Text(user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${user.phone} • ${user.location.isNotEmpty ? user.location : 'Location not set'}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _roleColor(user.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(user.role.toUpperCase(),
                                  style: TextStyle(
                                      color: _roleColor(user.role),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                            onTap: () => _showUserDetails(user),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showUserDetails(UserModel user) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n?.translate('phone') ?? 'Phone'}: ${user.phone}'),
            Text('${l10n?.translate('role') ?? 'Role'}: ${user.role}'),
            Text(
                'Location: ${user.location.isNotEmpty ? user.location : 'Not set'}'),
            Text(
                'Member since: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            if (user.totalOrders != null)
              Text(
                  '${l10n?.translate('total_orders') ?? 'Total orders'}: ${user.totalOrders}'),
            if (user.totalEarned != null)
              Text(
                  '${l10n?.translate('total_earned') ?? 'Total earned'}: ₹${user.totalEarned}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.translate('close') ?? 'Close'))
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.insert_chart,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        const SizedBox(height: 20),
        Text(l10n?.translate('download_reports') ?? 'Download Reports',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
            l10n?.translate('generate_detailed_reports') ??
                'Generate detailed reports for analysis',
            style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: Text(l10n?.translate('download_monthly_report') ??
              'Download Monthly Report'),
          style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
        ),
      ]),
    );
  }

  Widget _buildProfileTab() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
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
                colors: [kRedDark, kRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: kRed.withOpacity(0.3),
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
                    child: Text('🛡️', style: TextStyle(fontSize: 36)))),
            const SizedBox(height: 12),
            Text(l10n?.translate('admin') ?? 'Admin',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(
                l10n?.translate('platform_administrator') ??
                    'Platform Administrator',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4))),
                child: Text('🛡️  ${l10n?.translate('admin') ?? 'Admin'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _miniStat(
                  '${_stats['farmers']}',
                  l10n?.translate('farmer') ?? 'Farmer',
                  Icons.agriculture,
                  Colors.orange,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat(
                  '${_stats['buyers']}',
                  l10n?.translate('buyer') ?? 'Buyer',
                  Icons.shopping_cart,
                  Colors.blue,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat(
                  '${_stats['workers']}',
                  l10n?.translate('worker') ?? 'Worker',
                  Icons.work,
                  Colors.purple,
                  cardColor)),
        ]),
        const SizedBox(height: 20),
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
                ? (l10n?.translate('english') ?? 'English')
                : (localeProvider.locale.languageCode == 'hi'
                    ? (l10n?.translate('hindi') ?? 'Hindi')
                    : (l10n?.translate('marathi') ?? 'Marathi')),
            Colors.teal,
            cardColor,
            () => _showLanguageDialog()),
        const Divider(height: 16),
        _profileTile(
            Icons.dashboard_rounded,
            l10n?.translate('overview') ?? 'Overview',
            l10n?.translate('platform_statistics') ?? 'Platform statistics',
            kRed,
            cardColor,
            () => setState(() => _selectedIndex = 0)),
        _profileTile(
            Icons.people_rounded,
            l10n?.translate('manage_users') ?? 'Manage Users',
            l10n?.translate('view_all_users') ?? 'View all users',
            Colors.blue,
            cardColor,
            () => setState(() => _selectedIndex = 1)),
        _profileTile(
            Icons.bar_chart_rounded,
            l10n?.translate('reports') ?? 'Reports',
            l10n?.translate('download_analytics') ?? 'Download analytics',
            Colors.green,
            cardColor,
            () => setState(() => _selectedIndex = 2)),
        _profileTile(
            Icons.help_outline_rounded,
            l10n?.translate('help_support') ?? 'Help & Support',
            'support@krishilink.com',
            Colors.teal,
            cardColor,
            () => _showInfo(
                l10n?.translate('help_support') ?? 'Help & Support',
                l10n?.translate('help_support_info') ??
                    'Helpline: 1800-123-4567\nEmail: support@krishilink.com\n\nAvailable Mon-Sat, 8 AM - 8 PM')),
        _profileTile(
            Icons.info_outline_rounded,
            l10n?.translate('about_app') ?? 'About KrishiLink',
            '${l10n?.translate('version') ?? 'Version'} 1.0.0',
            Colors.grey.shade600,
            cardColor,
            () => _showInfo(
                l10n?.translate('about_app') ?? 'About KrishiLink',
                l10n?.translate('about_app_info') ??
                    'KrishiLink connects farmers directly to buyers, eliminating middlemen and ensuring fair prices.\n\nVersion 1.0.0\n(c) 2024 KrishiLink')),
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
        title: Text(l10n?.translate('select_language') ?? 'Select Language'),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
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
                  backgroundColor: kRed, foregroundColor: Colors.white),
              child: Text(l10n?.translate('close') ?? 'Close'))
        ],
      ),
    );
  }
}
