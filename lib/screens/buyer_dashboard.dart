import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../utils/app_localizations.dart';
import 'marketplace_screen.dart';
import 'tracking_screen.dart';
import 'landing_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _selectedIndex = 0;
  String _userName = 'Amit Shah';
  String _userPhone = '9876543210';
  String _userLocation = 'Mumbai, Maharashtra';
  List<OrderModel> _orders = [];

  static const kBlue = Color(0xFF1565C0);
  static const kBlueDark = Color(0xFF0D47A1);
  static const kBlueLight = Color(0xFF1976D2);

  final List<OrderModel> _demoOrders = [
    OrderModel(
      id: 1,
      productDocId: 'prod1',
      productName: 'Fresh Tomatoes',
      buyerId: 101,
      buyerName: 'Amit Shah',
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      quantity: 10,
      unit: 'kg',
      price: 25,
      totalAmount: 250,
      status: 'delivered',
      trackingStatus: 'delivered',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      deliveredDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 2,
      productDocId: 'prod2',
      productName: 'Green Chillies',
      buyerId: 101,
      buyerName: 'Amit Shah',
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      quantity: 5,
      unit: 'kg',
      price: 30,
      totalAmount: 150,
      status: 'in_transit',
      trackingStatus: 'in_transit',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 3,
      productDocId: 'prod3',
      productName: 'Organic Onions',
      buyerId: 101,
      buyerName: 'Amit Shah',
      farmerId: 2,
      farmerName: 'Suresh Yadav',
      quantity: 20,
      unit: 'kg',
      price: 20,
      totalAmount: 400,
      status: 'pending',
      trackingStatus: 'harvested',
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orders = List.from(_demoOrders);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return Colors.green;
      case 'in_transit': return Colors.blue;
      case 'confirmed': return Colors.orange;
      case 'pending': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case 'delivered': return l10n?.translate('delivered') ?? 'Delivered';
      case 'in_transit': return l10n?.translate('in_transit') ?? 'In Transit';
      case 'confirmed': return l10n?.translate('confirmed') ?? 'Confirmed';
      case 'pending': return l10n?.translate('pending') ?? 'Pending';
      case 'cancelled': return l10n?.translate('cancelled') ?? 'Cancelled';
      default: return status;
    }
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l10n?.translate('exit_app') ?? 'Exit App'),
            content: Text(l10n?.translate('exit_confirm') ?? 'Do you want to exit KrishiLink?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n?.translate('cancel') ?? 'Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(l10n?.translate('confirm') ?? 'Exit')),
            ],
          ),
        );
        return confirm == true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(l10n?.translate('app_name') ?? 'KrishiLink', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildOrdersTab(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: kBlue,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: l10n?.translate('home') ?? 'Home'),
            BottomNavigationBarItem(icon: const Icon(Icons.receipt_long_rounded), label: l10n?.translate('my_orders') ?? 'My Orders'),
            BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: l10n?.translate('profile') ?? 'Profile'),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
          backgroundColor: kBlue,
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: Text(l10n?.translate('browse_market') ?? 'Browse Market', style: const TextStyle(color: Colors.white)),
        )
            : null,
      ),
    );
  }

  Widget _buildHomeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final totalSpent = _orders.where((o) => o.status == 'delivered').fold(0.0, (sum, o) => sum + o.totalAmount);
    final activeOrders = _orders.where((o) => o.status != 'delivered' && o.status != 'cancelled').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kBlueDark, kBlueLight]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.person, size: 32, color: kBlue)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n?.translate('hello') ?? 'Welcome'}, $_userName!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(l10n?.translate('buy_fresh') ?? 'Buy fresh produce directly from farms', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
                    Text(_userLocation.split(',').first, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard(l10n?.translate('total_orders') ?? 'Total Orders', '${_orders.length}', Icons.shopping_bag, kBlue, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(l10n?.translate('active_orders') ?? 'Active', '$activeOrders', Icons.local_shipping, Colors.orange, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(l10n?.translate('total_spent') ?? 'Spent', '₹${totalSpent.toStringAsFixed(0)}', Icons.currency_rupee, Colors.green, isDark)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n?.translate('recent_orders') ?? 'Recent Orders', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: Text(l10n?.translate('see_all') ?? 'See All')),
            ],
          ),
          const SizedBox(height: 8),
          ..._orders.take(2).map((order) => _buildOrderCard(order, cardColor)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2A1A) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, size: 40, color: Colors.green.shade600),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n?.translate('browse_market') ?? 'Browse Marketplace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        Text(l10n?.translate('buy_fresh') ?? 'Buy fresh produce directly from farmers'),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.green.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_orders.isEmpty) {
      return Center(child: Text(l10n?.translate('no_orders') ?? 'No orders yet. Start shopping!'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) => _buildOrderCard(_orders[index], cardColor),
    );
  }

  Widget _buildOrderCard(OrderModel order, Color cardColor) {
    final statusColor = _statusColor(order.status);
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${l10n?.translate('order_id') ?? 'Order'} #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel(order.status, context), style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text('${order.productName} — ${order.quantity} ${order.unit}', style: const TextStyle(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(order.farmerName, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const Spacer(),
                Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            if (order.status != 'delivered' && order.status != 'cancelled')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingScreen(order: order))),
                    icon: const Icon(Icons.location_on, size: 16),
                    label: Text(l10n?.translate('track_order') ?? 'Track Order'),
                    style: OutlinedButton.styleFrom(foregroundColor: kBlue, side: const BorderSide(color: kBlue)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final totalSpent = _orders.where((o) => o.status == 'delivered').fold(0.0, (s, o) => s + o.totalAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kBlueDark, kBlueLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle), child: const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Text('🛒', style: TextStyle(fontSize: 38)))),
                const SizedBox(height: 12),
                Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                if (_userPhone.isNotEmpty) Text(_userPhone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(_userLocation, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.4))), child: Text('🛒  ${l10n?.translate('buyer') ?? 'Buyer'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _miniStat('${_orders.length}', l10n?.translate('orders') ?? 'Orders', Icons.shopping_bag_rounded, kBlue, cardColor)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('${_orders.where((o) => o.status != 'delivered').length}', l10n?.translate('active') ?? 'Active', Icons.local_shipping_rounded, Colors.orange, cardColor)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('₹${totalSpent.toStringAsFixed(0)}', l10n?.translate('spent') ?? 'Spent', Icons.currency_rupee_rounded, Colors.green, cardColor)),
            ],
          ),
          const SizedBox(height: 20),
          _profileTile(Icons.shopping_bag_rounded, l10n?.translate('my_orders') ?? 'My Orders', '${_orders.length} ${l10n?.translate('orders') ?? 'orders'}', kBlue, cardColor, () => setState(() => _selectedIndex = 1)),
          _profileTile(Icons.storefront_rounded, l10n?.translate('marketplace') ?? 'Marketplace', l10n?.translate('buy_fresh') ?? 'Browse fresh produce', Colors.green, cardColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketplaceScreen()))),
          _profileTile(Icons.help_outline_rounded, l10n?.translate('help_support') ?? 'Help & Support', 'support@krishilink.com', Colors.teal, cardColor, () => _showInfo(l10n?.translate('help_support') ?? 'Help & Support', '📞 ${l10n?.translate('helpline') ?? 'Helpline'}: 1800-123-4567\n📧 ${l10n?.translate('email') ?? 'Email'}: support@krishilink.com')),
          _profileTile(Icons.info_outline_rounded, l10n?.translate('about_app') ?? 'About KrishiLink', '${l10n?.translate('version') ?? 'Version'} 1.0.0', Colors.grey.shade600, cardColor, () => _showInfo(l10n?.translate('about_app') ?? 'About KrishiLink', '🌾 KrishiLink connects farmers directly to buyers.\n\nVersion 1.0.0\n© 2024 KrishiLink')),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(onPressed: _confirmLogout, icon: const Icon(Icons.logout_rounded, color: Colors.red), label: Text(l10n?.translate('logout') ?? 'Logout', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        ],
      ),
    );
  }

  Widget _miniStat(String val, String label, IconData icon, Color color, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ]),
    );
  }

  Widget _profileTile(IconData icon, String title, String sub, Color color, Color cardColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }

  void _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [const Icon(Icons.logout_rounded, color: Colors.red), const SizedBox(width: 8), const Text('Logout')]),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingScreen()), (_) => false);
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
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white), child: Text(l10n?.translate('close') ?? 'Close'))],
      ),
    );
  }
}