import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/job_model.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  String _userName = 'Ramesh Patel';
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<JobModel> _myJobs = [];
  static const kGreen = Color(0xFF2E7D32);
  static const kGreenLight = Color(0xFF66BB6A);
  static const kGreenBg = Color(0xFFF1F8E9);
  static const kAmber = Color(0xFFFF8F00);

  int _nextId = 4;
  int _nextOrderId = 2;
  int _nextJobId = 2;

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
      status: 'pending',
      trackingStatus: 'harvested',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<JobModel> _demoJobs = [
    JobModel(
      id: 1,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      title: 'Harvesting Helper',
      description: 'Need workers for tomato harvesting',
      location: 'Pune',
      wage: 350,
      duration: '5 days',
      workersNeeded: 10,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      applicationsCount: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _products = List.from(_demoProducts);
    _orders = List.from(_demoOrders);
    _myJobs = List.from(_demoJobs);
    _nextId = _products.length + 1;
    _nextOrderId = _orders.length + 1;
    _nextJobId = _myJobs.length + 1;
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

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final marketCtrl = TextEditingController();
    String unit = 'kg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: keyboardPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('➕  Add Product',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kGreen)),
                  const SizedBox(height: 16),
                  _inputField(
                      nameCtrl, 'Product Name', '🌾  e.g. Fresh Tomatoes'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _inputField(qtyCtrl, 'Quantity', '',
                              isNumber: true)),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          value: unit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          items: ['kg', 'g', 'ton', 'dozen', 'piece', 'liter']
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => unit = v ?? 'kg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _inputField(priceCtrl, 'Price (₹)', '',
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _inputField(marketCtrl, 'Market Price (₹)', '',
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty &&
                            priceCtrl.text.isNotEmpty &&
                            marketCtrl.text.isNotEmpty) {
                          final price = double.tryParse(priceCtrl.text) ?? 0;
                          final marketPrice =
                              double.tryParse(marketCtrl.text) ?? price;
                          final newProduct = ProductModel(
                            docId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            id: _nextId,
                            farmerId: 1,
                            farmerUid: 'farmer_uid',
                            farmerName: _userName,
                            name: nameCtrl.text.trim(),
                            quantity: double.tryParse(qtyCtrl.text) ?? 0,
                            unit: unit,
                            price: price,
                            marketPrice: marketPrice,
                            description: '',
                            images: null,
                            status: 'available',
                            createdAt: DateTime.now(),
                          );
                          setState(() {
                            _products.insert(0, newProduct);
                            _nextId++;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('✅ Product added successfully'),
                                backgroundColor: kGreen,
                                behavior: SnackBarBehavior.floating),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Add Product',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPostJobDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final wageCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final workersCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: keyboardPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('➕  Post a Job',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kGreen)),
                  const SizedBox(height: 16),
                  _inputField(titleCtrl, 'Job Title', 'e.g. Harvesting Helper'),
                  const SizedBox(height: 12),
                  _inputField(descCtrl, 'Description', 'Details about work'),
                  const SizedBox(height: 12),
                  _inputField(locCtrl, 'Location', 'City / Village'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _inputField(wageCtrl, 'Wage (₹/day)', '',
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _inputField(
                              durationCtrl, 'Duration', 'e.g. 3 days')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _inputField(workersCtrl, 'Workers Needed', '',
                      isNumber: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty) {
                          final newJob = JobModel(
                            docId: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            id: _nextJobId,
                            farmerId: 1,
                            farmerUid: 'farmer_uid',
                            farmerName: _userName,
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            location: locCtrl.text.trim(),
                            wage: double.tryParse(wageCtrl.text) ?? 0,
                            duration: durationCtrl.text.trim(),
                            workersNeeded: int.tryParse(workersCtrl.text) ?? 1,
                            status: 'open',
                            createdAt: DateTime.now(),
                            applicationsCount: 0,
                          );
                          setState(() {
                            _myJobs.insert(0, newJob);
                            _nextJobId++;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Job posted successfully!'),
                                backgroundColor: kGreen,
                                behavior: SnackBarBehavior.floating),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Post Job',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to remove this product?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _products.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Product removed'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(
      String docId, String status, String trackingStatus) async {
    setState(() {
      final index = _orders.indexWhere((o) => o.docId == docId);
      if (index != -1) {
        _orders[index] = _orders[index]
            .copyWith(status: status, trackingStatus: trackingStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Order $status'),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating),
    );
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
            const Text('KrishiLink',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
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
          _buildOrdersTab(),
          _buildJobsTab(),
          _buildPlaceholder('Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _showAddProductDialog,
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Product',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : (_selectedIndex == 3
              ? FloatingActionButton.extended(
                  onPressed: _showPostJobDialog,
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.post_add),
                  label: const Text('Post Job',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              : null),
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
    final totalEarnings = _orders
        .where((o) => o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.totalAmount);

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
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: kGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.agriculture_rounded,
                      size: 34, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jai Kisan, $_userName! 🌾',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Your farm dashboard is ready',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
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
                      isDark ? const Color(0xFF1A2A1A) : kGreenBg)),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      'Orders',
                      '${_orders.length}',
                      Icons.receipt_long_rounded,
                      kAmber,
                      isDark
                          ? const Color(0xFF2A2A1A)
                          : const Color(0xFFFFF8E1))),
              const SizedBox(width: 10),
              Expanded(
                  child: _statCard(
                      'Earned',
                      '₹${totalEarnings.toStringAsFixed(0)}',
                      Icons.currency_rupee_rounded,
                      Colors.blue.shade700,
                      isDark ? const Color(0xFF1A1A2A) : Colors.blue.shade50)),
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
                  ]),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                        borderRadius: BorderRadius.circular(12)),
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
            const Text('Tap + Add Product to list your crops',
                style: TextStyle(color: Colors.grey)),
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
              ]),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                      borderRadius: BorderRadius.circular(14)),
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
                                border:
                                    Border.all(color: Colors.green.shade200)),
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
                        Colors.red.shade400, () => _deleteProduct(index)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_orders.isEmpty) {
      return Center(
          child: Text('No orders yet',
              style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final (color, label, icon) = _orderStatus(order.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
              ]),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey.shade500)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(label,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    '${_emojiFor(order.productName)}  ${order.productName} — ${order.quantity} ${order.unit}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(order.buyerName,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                    const Spacer(),
                    Text('₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                            fontSize: 16)),
                  ],
                ),
                if (order.status == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateOrderStatus(
                                order.docId, 'confirmed', 'packed'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white),
                            child: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateOrderStatus(
                                order.docId, 'cancelled', 'cancelled'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (order.status == 'confirmed' &&
                    order.trackingStatus != 'delivered')
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        if (order.trackingStatus == 'packed')
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateOrderStatus(
                                  order.docId, 'processing', 'in_transit'),
                              child: const Text('Mark In Transit'),
                            ),
                          ),
                        if (order.trackingStatus == 'in_transit')
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateOrderStatus(
                                  order.docId, 'delivered', 'delivered'),
                              child: const Text('Mark Delivered'),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_myJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📋', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            const Text('No job posts yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Tap + to post a job',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myJobs.length,
      itemBuilder: (context, index) {
        final job = _myJobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
              ]),
          child: ListTile(
            leading: const Icon(Icons.work, color: kGreen),
            title: Text(job.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${job.location} • ${job.formattedWage} • ${job.workersNeeded} needed'),
            trailing: IconButton(
              icon: const Icon(Icons.people_rounded, color: kGreen),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${job.applicationsCount ?? 0} applications received'),
                      backgroundColor: kGreen),
                );
              },
            ),
            onTap: () => _showJobDetails(job),
          ),
        );
      },
    );
  }

  void _showJobDetails(JobModel job) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(job.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${job.location}'),
            Text('Wage: ${job.formattedWage}'),
            Text('Duration: ${job.duration}'),
            Text('Workers Needed: ${job.workersNeeded}'),
            const SizedBox(height: 8),
            Text('Description: ${job.description}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  (Color, String, IconData) _orderStatus(String s) {
    switch (s) {
      case 'delivered':
        return (Colors.green, 'DELIVERED', Icons.check_circle_rounded);
      case 'in_transit':
        return (Colors.blue, 'IN TRANSIT', Icons.local_shipping_rounded);
      case 'confirmed':
        return (Colors.orange, 'CONFIRMED', Icons.check_circle_outline);
      case 'cancelled':
        return (Colors.red, 'CANCELLED', Icons.cancel);
      default:
        return (Colors.orange, 'PENDING', Icons.hourglass_empty_rounded);
    }
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
          border: Border.all(color: color.withOpacity(0.2))),
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
                color: kGreen, borderRadius: BorderRadius.circular(4))),
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
