import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';

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

  static const kRed = Color(0xFFC62828);
  static const kRedDark = Color(0xFFB71C1C);

  final List<UserModel> _demoUsers = [
    UserModel(
        id: 1,
        phone: '9876543210',
        name: 'Ramesh Patel',
        role: 'farmer',
        location: 'Pune',
        createdAt: DateTime.now(),
        rating: 4.8,
        totalOrders: 15,
        totalEarned: 12500),
    UserModel(
        id: 2,
        phone: '9876543211',
        name: 'Suresh Yadav',
        role: 'farmer',
        location: 'Nashik',
        createdAt: DateTime.now(),
        rating: 4.5,
        totalOrders: 8,
        totalEarned: 7200),
    UserModel(
        id: 3,
        phone: '9876543212',
        name: 'Amit Shah',
        role: 'buyer',
        location: 'Mumbai',
        createdAt: DateTime.now(),
        totalOrders: 5),
    UserModel(
        id: 4,
        phone: '9876543213',
        name: 'Mahesh Jadhav',
        role: 'worker',
        location: 'Satara',
        createdAt: DateTime.now()),
    UserModel(
        id: 5,
        phone: '9876543214',
        name: 'Anita Deshmukh',
        role: 'farmer',
        location: 'Kolhapur',
        createdAt: DateTime.now(),
        rating: 4.9,
        totalOrders: 22,
        totalEarned: 18900),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _allUsers = List.from(_demoUsers);
  }

  Future<void> _loadStats() async {
    setState(() {
      _stats = {
        'farmers': _allUsers.where((u) => u.role == 'farmer').length,
        'buyers': _allUsers.where((u) => u.role == 'buyer').length,
        'workers': _allUsers.where((u) => u.role == 'worker').length,
        'orders': 45,
        'open_jobs': 8,
        'total_value': 385000.0,
      };
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white, size: 24),
          const SizedBox(width: 8),
          const Text('KrishiLink Admin',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
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
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Admin Dashboard',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Text('Platform Performance Overview',
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
          const Text('Weekly Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          child: filteredUsers.isEmpty
              ? const Center(child: Text('No users found'))
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
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${user.phone} • ${user.location.isNotEmpty ? user.location : 'Location not set'}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: _roleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20)),
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

  Widget _filterChip(String label, String filterValue, int count) {
    final isSelected = _userFilter == filterValue;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _userFilter = selected ? filterValue : 'all';
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: kRed.withOpacity(0.2),
      checkmarkColor: kRed,
      labelStyle: TextStyle(
          color: isSelected ? kRed : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${user.phone}'),
            Text('Role: ${user.role}'),
            Text(
                'Location: ${user.location.isNotEmpty ? user.location : 'Not set'}'),
            Text(
                'Member since: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
            if (user.totalOrders != null)
              Text('Total orders: ${user.totalOrders}'),
            if (user.totalEarned != null)
              Text('Total earned: ₹${user.totalEarned}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text('Download Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Generate detailed reports for analysis',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Download Monthly Report'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kRed,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
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
            const Text('Admin',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Platform Administrator',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4))),
                child: const Text('🛡️  Admin',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _miniStat('${_stats['farmers']}', 'Farmers',
                  Icons.agriculture, Colors.orange, cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat('${_stats['buyers']}', 'Buyers',
                  Icons.shopping_cart, Colors.blue, cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat('${_stats['workers']}', 'Workers', Icons.work,
                  Colors.purple, cardColor)),
        ]),
        const SizedBox(height: 20),
        _profileTile(Icons.dashboard_rounded, 'Overview', 'Platform statistics',
            kRed, cardColor, () => setState(() => _selectedIndex = 0)),
        _profileTile(Icons.people_rounded, 'Manage Users', 'View all users',
            Colors.blue, cardColor, () => setState(() => _selectedIndex = 1)),
        _profileTile(Icons.bar_chart_rounded, 'Reports', 'Download analytics',
            Colors.green, cardColor, () => setState(() => _selectedIndex = 2)),
        _profileTile(
            Icons.help_outline_rounded,
            'Help & Support',
            'support@krishilink.com',
            Colors.teal,
            cardColor,
            () => _showInfo('Help & Support',
                '📞 Helpline: 1800-123-4567\n📧 Email: support@krishilink.com\n\nAvailable Mon–Sat, 8 AM – 8 PM')),
        _profileTile(
            Icons.info_outline_rounded,
            'About KrishiLink',
            'Version 1.0.0',
            Colors.grey.shade600,
            cardColor,
            () => _showInfo('About KrishiLink',
                '🌾 KrishiLink connects farmers directly to buyers, eliminating middlemen and ensuring fair prices.\n\nVersion 1.0.0\n© 2024 KrishiLink')),
        const SizedBox(height: 20),
        SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))))),
      ]),
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

  void _showInfo(String title, String content) {
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
              child: const Text('Close'))
        ],
      ),
    );
  }
}
