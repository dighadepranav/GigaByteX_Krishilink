import 'package:flutter/material.dart';
import '../models/product_model.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  String _userName = 'Farmer';
  List<ProductModel> _products = [];
  static const kGreen = Color(0xFF2E7D32);
  static const kGreenLight = Color(0xFF66BB6A);
  static const kGreenBg = Color(0xFFF1F8E9);
  static const kAmber = Color(0xFFFF8F00);

  // Demo products data
  final List<ProductModel> _demoProducts = [
    ProductModel(
      id: 1,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      name: 'Fresh Tomatoes',
      quantity: 100,
      unit: 'kg',
      price: 25,
      marketPrice: 40,
      status: 'available',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 2,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      name: 'Green Chillies',
      quantity: 50,
      unit: 'kg',
      price: 30,
      marketPrice: 60,
      status: 'available',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 3,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      name: 'Onions',
      quantity: 200,
      unit: 'kg',
      price: 20,
      marketPrice: 35,
      status: 'available',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _products = _demoProducts;
  }

  static const Map<String, String> _cropEmoji = {
    'tomato': '🍅',
    'chilli': '🌶️',
    'onion': '🧅',
    'potato': '🥔',
    'brinjal': '🍆',
    'carrot': '🥕',
    'corn': '🌽',
    'wheat': '🌾',
  };

  String _emojiFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _cropEmoji.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '🥬';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 26),
            const SizedBox(width: 8),
            const Text(
              'KrishiLink',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildProductsTab(),
          _buildPlaceholder('Orders'),
          _buildPlaceholder('Job Requests'),
          _buildPlaceholder('Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Product',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: kGreen,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), label: 'Job Requests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final totalEarnings = 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), kGreen, kGreenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.agriculture_rounded,
                      size: 34, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jai Kisan, $_userName! 🌾',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your farm dashboard is ready',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _statCard(
                    'Products',
                    '${_products.length}',
                    Icons.inventory_2_rounded,
                    kGreen,
                    isDark ? const Color(0xFF1A2A1A) : kGreenBg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                    'Orders',
                    '0',
                    Icons.receipt_long_rounded,
                    kAmber,
                    isDark ? const Color(0xFF2A2A1A) : const Color(0xFFFFF8E1)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                    'Earned',
                    '₹${totalEarnings.toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                    Colors.blue.shade700,
                    isDark ? const Color(0xFF1A1A2A) : Colors.blue.shade50),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Price Comparison'),
          const SizedBox(height: 10),
          ..._products.map((product) {
            final saving = product.marketPrice - product.price;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 6)
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Text(_emojiFor(product.name),
                            style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                            '${product.quantity} ${product.unit} available stock',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Your price: ₹${product.price}/${product.unit}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kGreen,
                              fontSize: 13)),
                      Text('Market price: ₹${product.marketPrice}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('Save ₹${saving.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: kGreen,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('No products yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Tap + Add Product to list your crops',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                      child: Text(_emojiFor(product.name),
                          style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(
                          '${product.quantity} ${product.unit}  •  ₹${product.price}/${product.unit}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text('Mkt ₹${product.marketPrice}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: kGreen,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _actionBtn(Icons.edit_rounded, Colors.orange, () {}),
                    const SizedBox(height: 6),
                    _actionBtn(Icons.delete_outline_rounded,
                        Colors.red.shade400, () {}),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              color: kGreen, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20))),
      ],
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('$title coming soon',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }
}
