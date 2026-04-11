import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/app_localizations.dart';
import '../utils/theme_provider.dart';
import '../utils/locale_provider.dart';
import '../services/firestore_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/job_model.dart';
import 'landing_screen.dart';
import 'farmer_job_applications_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  String _userName = 'Farmer';
  String _userPhone = '';
  String _userLocation = 'Pune, Maharashtra';
  String _userUid = '';

  static const kGreen = Color(0xFF2E7D32);
  static const kGreenLight = Color(0xFF66BB6A);
  static const kGreenBg = Color(0xFFF1F8E9);
  static const kAmber = Color(0xFFFF8F00);

  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<JobModel> _myJobs = [];
  bool _isLoading = false;

  StreamSubscription? _productsSub;
  StreamSubscription? _ordersSub;
  StreamSubscription? _jobsSub;

  static const Map<String, String> _cropEmoji = {
    'tomatoes': '🍅',
    'tomato': '🍅',
    'chilli': '🌶️',
    'chillies': '🌶️',
    'potato': '🥔',
    'potatoes': '🥔',
    'onion': '🧅',
    'onions': '🧅',
    'brinjal': '🍆',
    'eggplant': '🍆',
    'carrot': '🥕',
    'carrots': '🥕',
    'corn': '🌽',
    'wheat': '🌾',
    'rice': '🌾',
  };

  String _emojiFor(String name) {
    final lower = name.toLowerCase();
    for (final entry in _cropEmoji.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '🥬';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Farmer';
      _userPhone = prefs.getString('userPhone') ?? '';
      _userLocation = prefs.getString('userLocation') ?? 'Pune, Maharashtra';
      _userUid = prefs.getString('userUid') ?? '';
    });
    _initStreams();
    await FirestoreService().checkAndAutoDeliverOrders(_userUid, 'farmer');
  }

  void _initStreams() {
    if (_userUid.isEmpty) return;
    _productsSub?.cancel();
    _ordersSub?.cancel();
    _jobsSub?.cancel();

    _productsSub =
        FirestoreService().streamFarmerProducts(_userUid).listen((products) {
          if (mounted) setState(() => _products = products);
        });

    _ordersSub =
        FirestoreService().streamFarmerOrders(_userUid).listen((orders) {
          if (mounted) setState(() => _orders = orders);
        });

    _jobsSub = FirestoreService().streamFarmerJobs(_userUid).listen((jobs) {
      if (mounted) setState(() => _myJobs = jobs);
    });
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _ordersSub?.cancel();
    _jobsSub?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingScreen()),
          (_) => false,
    );
  }

  void _showAddProductDialog() => _showProductDialog(null);

  void _showProductDialog(ProductModel? existing) {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final qtyCtrl =
    TextEditingController(text: existing?.quantity.toString() ?? '');
    final priceCtrl =
    TextEditingController(text: existing?.price.toString() ?? '');
    final marketCtrl =
    TextEditingController(text: existing?.marketPrice.toString() ?? '');
    String unit = existing?.unit ?? 'kg';
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          StatefulBuilder(
            builder: (context, setSheetState) {
              final keyboardPadding = MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom
                  .clamp(0.0, double.infinity);
              return Padding(
                padding: EdgeInsets.only(bottom: keyboardPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .cardColor,
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
                                  borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(height: 16),
                      Text(
                          isEdit
                              ? '✏️  ${l10n?.translate('edit_product') ??
                              'Edit Product'}'
                              : '➕  ${l10n?.translate('add_product') ??
                              'Add Product'}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kGreen)),
                      const SizedBox(height: 16),
                      _inputField(
                          nameCtrl,
                          l10n?.translate('product_name') ?? 'Product Name',
                          '🌾  e.g. Fresh Tomatoes'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _inputField(qtyCtrl,
                                l10n?.translate('quantity') ?? 'Quantity', '',
                                isNumber: true)),
                        const SizedBox(width: 10),
                        SizedBox(
                            width: 110,
                            child: DropdownButtonFormField<String>(
                              value: unit,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n?.translate('unit') ?? 'Unit',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              items: [
                                'kg',
                                'g',
                                'ton',
                                'dozen',
                                'piece',
                                'liter'
                              ]
                                  .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) =>
                                  setSheetState(() => unit = v ?? 'kg'),
                            )),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _inputField(priceCtrl,
                                '${l10n?.translate('price') ?? 'Price'} (₹)',
                                '',
                                isNumber: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _inputField(
                                marketCtrl,
                                '${l10n?.translate('market_price') ??
                                    'Market Price'} (₹)',
                                '',
                                isNumber: true)),
                      ]),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameCtrl.text.isNotEmpty &&
                                  priceCtrl.text.isNotEmpty &&
                                  marketCtrl.text.isNotEmpty) {
                                final price = double.tryParse(priceCtrl.text) ??
                                    0;
                                final marketPrice =
                                    double.tryParse(marketCtrl.text) ?? price;
                                final productData = ProductModel(
                                  docId: existing?.docId ?? '',
                                  id: existing?.id ?? 0,
                                  farmerId: 0,
                                  farmerUid: _userUid,
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
                                  rating: null,
                                  totalSold: null,
                                );
                                setState(() => _isLoading = true);
                                try {
                                  if (isEdit) {
                                    await FirestoreService()
                                        .updateProduct(productData);
                                  } else {
                                    await FirestoreService()
                                        .addProduct(productData, _userUid);
                                  }
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '✅ ${l10n?.translate('success') ??
                                                  'Success'}'),
                                          backgroundColor: kGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12))));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${l10n?.translate(
                                                  'error_prefix') ??
                                                  'Error'}: $e'),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating));
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            child: Text(
                                isEdit
                                    ? (l10n?.translate('save') ?? 'Save')
                                    : (l10n?.translate('add_product') ??
                                    'Add Product'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          )),
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

  void _showPostJobDialog() {
    final l10n = AppLocalizations.of(context);
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
      builder: (_) =>
          StatefulBuilder(
            builder: (context, setSheetState) {
              final keyboardPadding = MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom
                  .clamp(0.0, double.infinity);
              return Padding(
                padding: EdgeInsets.only(bottom: keyboardPadding),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .cardColor,
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24))),
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
                                  borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(height: 16),
                      Text('➕  ${l10n?.translate('post_job') ?? 'Post a Job'}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kGreen)),
                      const SizedBox(height: 16),
                      _inputField(
                          titleCtrl,
                          l10n?.translate('job_title') ?? 'Job Title',
                          'e.g. Harvesting Helper'),
                      const SizedBox(height: 12),
                      _inputField(
                          descCtrl,
                          l10n?.translate('description') ?? 'Description',
                          'Details about work'),
                      const SizedBox(height: 12),
                      _inputField(
                          locCtrl,
                          l10n?.translate('location') ?? 'Location',
                          'City / Village'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _inputField(wageCtrl,
                                '${l10n?.translate('wage') ?? 'Wage'} (₹/day)',
                                '',
                                isNumber: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _inputField(
                                durationCtrl,
                                l10n?.translate('duration') ?? 'Duration',
                                'e.g. 3 days')),
                      ]),
                      const SizedBox(height: 12),
                      _inputField(workersCtrl,
                          l10n?.translate('workers_needed') ?? 'Workers Needed',
                          '',
                          isNumber: true),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (titleCtrl.text.isNotEmpty) {
                                final job = JobModel(
                                  id: 0,
                                  farmerId: 0,
                                  farmerUid: _userUid,
                                  farmerName: _userName,
                                  title: titleCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  location: locCtrl.text.trim(),
                                  wage: double.tryParse(wageCtrl.text) ?? 0,
                                  duration: durationCtrl.text.trim(),
                                  workersNeeded:
                                  int.tryParse(workersCtrl.text) ?? 1,
                                  status: 'open',
                                  createdAt: DateTime.now(),
                                  applicationsCount: 0,
                                  isSaved: false,
                                  isApplied: false,
                                  postedAt: null,
                                );
                                setState(() => _isLoading = true);
                                try {
                                  await FirestoreService().addJob(
                                      job, _userUid);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              l10n?.translate('success') ??
                                                  'Job posted successfully!'),
                                          backgroundColor: kGreen,
                                          behavior: SnackBarBehavior.floating));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              '${l10n?.translate(
                                                  'error_prefix') ??
                                                  'Error'}: $e'),
                                          backgroundColor: Colors.red));
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            child: Text(l10n?.translate('post_job') ??
                                'Post Job',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> _deleteJob(String jobDocId) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(l10n?.translate('delete_job') ?? 'Delete Job'),
            content: Text(l10n?.translate('delete_job_confirm') ??
                'Are you sure you want to delete this job?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n?.translate('cancel') ?? 'Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(l10n?.translate('delete') ?? 'Delete')),
            ],
          ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await FirestoreService().deleteJob(jobDocId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
        Text(l10n?.translate('job_deleted') ?? 'Job deleted successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n?.translate('error_prefix') ?? 'Error'}: $e'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String docId, String status,
      String trackingStatus) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      await FirestoreService().updateOrderStatus(docId, status, trackingStatus);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${l10n?.translate('status') ?? 'Status'}: ${l10n?.translate(
                  status) ?? status}'),
          backgroundColor: kGreen,
          behavior: SnackBarBehavior.floating));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n?.translate('error_prefix') ?? 'Error'}: $e'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) =>
              AlertDialog(
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: Text(l10n?.translate('confirm') ?? 'Exit')),
                ],
              ),
        );
        return confirm == true;
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(children: [
            Image.asset('assets/images/logo.png',
                height: 28,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.eco, color: Colors.white, size: 26)),
            const SizedBox(width: 8),
            Text(l10n?.translate('app_name') ?? 'KrishiLink',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
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
            _buildProfileTab(),
          ],
        ),
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton.extended(
            onPressed: _showAddProductDialog,
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(l10n?.translate('add_product') ?? 'Add Product',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)))
            : (_selectedIndex == 3
            ? FloatingActionButton.extended(
            onPressed: _showPostJobDialog,
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.post_add),
            label: Text(l10n?.translate('post_job') ?? 'Post Job',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)))
            : null),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: kGreen,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: l10n?.translate('home') ?? 'Home'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.inventory_2_rounded),
                label: l10n?.translate('products') ?? 'Products'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_rounded),
                label: l10n?.translate('orders') ?? 'Orders'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.work_outline),
                label: l10n?.translate('job_requests') ?? 'Job Requests'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: l10n?.translate('profile') ?? 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final l10n = AppLocalizations.of(context);
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
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.agriculture_rounded,
                      size: 34, color: Colors.white)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${l10n?.translate('jai_kisan') ??
                                'Jai Kisan'}, $_userName! 🌾',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            l10n?.translate('farm_dashboard_ready') ??
                                'Your farm dashboard is ready',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ])),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _statCard(
                    l10n?.translate('products') ?? 'Products',
                    '${_products.length}',
                    Icons.inventory_2_rounded,
                    kGreen,
                    isDark ? const Color(0xFF1A2A1A) : kGreenBg)),
            const SizedBox(width: 10),
            Expanded(
                child: _statCard(
                    l10n?.translate('orders') ?? 'Orders',
                    '${_orders.length}',
                    Icons.receipt_long_rounded,
                    kAmber,
                    isDark
                        ? const Color(0xFF2A2A1A)
                        : const Color(0xFFFFF8E1))),
            const SizedBox(width: 10),
            Expanded(
                child: _statCard(
                    l10n?.translate('earned') ?? 'Earned',
                    '₹${totalEarnings.toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                    Colors.blue.shade700,
                    isDark ? const Color(0xFF1A1A2A) : Colors.blue.shade50)),
          ]),
          const SizedBox(height: 24),
          _sectionTitle(
              l10n?.translate('price_comparison') ?? 'Price Comparison'),
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
              child: Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child: Text(_emojiFor(product.name),
                            style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                              '${product.quantity} ${product.unit} ${l10n
                                  ?.translate('available_stock') ??
                                  'available stock'}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                      '${l10n?.translate('your_price') ??
                          'Your Price'}: ₹${product.price}/${product.unit}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                          fontSize: 13)),
                  Text(
                      '${l10n?.translate('market_price') ??
                          'Market Price'}: ₹${product.marketPrice}',
                      style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                          '${l10n?.translate('save_amount') ?? 'Save'} ₹${saving
                              .toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: kGreen,
                              fontWeight: FontWeight.bold))),
                ]),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_products.isEmpty && !_isLoading) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🌱', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            Text(l10n?.translate('no_products') ?? 'No products yet',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
                l10n?.translate('add_product') ??
                    'Tap + Add Product to list your crops',
                style: TextStyle(color: Colors.grey.shade600)),
          ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final saving = product.marketPrice - product.price;
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
            child: Row(children: [
              Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2A1A) : kGreenBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(_emojiFor(product.name),
                          style: const TextStyle(fontSize: 26)))),
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
                            '${product.quantity} ${product.unit}  •  ₹${product
                                .price}/${product.unit}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.green.shade200)),
                              child: Text(
                                  '${l10n?.translate('market_short') ??
                                      'Mkt'} ₹${product.marketPrice}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: kGreen,
                                      fontWeight: FontWeight.w600))),
                        ]),
                      ])),
              Column(children: [
                _actionBtn(Icons.edit_rounded, Colors.orange,
                        () => _showProductDialog(product)),
                const SizedBox(height: 6),
                _actionBtn(Icons.delete_outline_rounded, Colors.red.shade400,
                        () async {
                      setState(() => _isLoading = true);
                      try {
                        await FirestoreService().deleteProduct(product.docId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                l10n?.translate('delete') ?? 'Product removed'),
                            backgroundColor: Colors.red.shade600,
                            behavior: SnackBarBehavior.floating));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${l10n?.translate('error_prefix') ??
                                    'Error'}: $e'),
                            backgroundColor: Colors.red));
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }),
              ]),
            ]),
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
          child: Icon(icon, color: color, size: 18)),
    );
  }

  Widget _buildOrdersTab() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final l10n = AppLocalizations.of(context);
    if (_orders.isEmpty) {
      return Center(
          child: Text(l10n?.translate('no_orders') ?? 'No orders yet',
              style: TextStyle(color: Colors.grey.shade600)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final (color, label, icon) = _orderStatus(order.status, context);
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
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${l10n?.translate('order_id') ?? 'Order'} #${order.id}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade500)),
                Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))
                    ])),
              ]),
              const SizedBox(height: 8),
              Text(
                  '${_emojiFor(order.productName)}  ${order
                      .productName} — ${order.quantity} ${order.unit}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.storefront_rounded,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(order.buyerName,
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const Spacer(),
                Text('₹${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kGreen,
                        fontSize: 16)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Buyer: ${order.buyerPhone.isNotEmpty
                        ? order.buyerPhone
                        : "Not provided"}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Delivery: ${order.deliveryAddress ?? "Not specified"}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.payment, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Payment: ${order.paymentMethodLabel}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ]),
              if (order.status == 'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () =>
                                _updateOrderStatus(
                                    order.docId, 'confirmed', 'packed'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white),
                            child:
                            Text(l10n?.translate('accept') ?? 'Accept'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () =>
                                _updateOrderStatus(
                                    order.docId, 'rejected', 'cancelled'),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red),
                            child:
                            Text(l10n?.translate('reject') ?? 'Reject'))),
                  ]),
                ),
              if (order.status == 'confirmed' &&
                  order.trackingStatus != 'delivered')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(children: [
                    if (order.trackingStatus == 'packed')
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () =>
                                  _updateOrderStatus(
                                      order.docId, 'processing', 'in_transit'),
                              child: Text(l10n?.translate('mark_in_transit') ??
                                  'Mark In Transit'))),
                    if (order.trackingStatus == 'in_transit')
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () =>
                                  _updateOrderStatus(
                                      order.docId, 'delivered', 'delivered'),
                              child: Text(l10n?.translate('mark_delivered') ??
                                  'Mark Delivered'))),
                  ]),
                ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    if (_myJobs.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📋', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text(l10n?.translate('no_jobs') ?? 'No job posts yet',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(l10n?.translate('tap_post_job') ?? 'Tap + to post a job',
                style: const TextStyle(color: Colors.grey)),
          ]));
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
                '${job.location} • ₹${job.wage}/day • ${job
                    .workersNeeded} ${l10n?.translate('workers_needed') ??
                    'workers needed'}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.people_rounded, color: kGreen),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FarmerJobApplicationsScreen(
                                  jobDocId: job.docId)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteJob(job.docId),
              ),
            ]),
            onTap: () => _showJobDetails(job),
          ),
        );
      },
    );
  }

  void _showJobDetails(JobModel job) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(job.title),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${l10n?.translate('location') ?? 'Location'}: ${job
                          .location}'),
                  Text(
                      '${l10n?.translate('wage') ?? 'Wage'}: ₹${job.wage}/day'),
                  Text(
                      '${l10n?.translate('duration') ?? 'Duration'}: ${job
                          .duration}'),
                  Text(
                      '${l10n?.translate('workers_needed') ??
                          'Workers needed'}: ${job.workersNeeded}'),
                  const SizedBox(height: 8),
                  Text(
                      '${l10n?.translate('description') ?? 'Description'}: ${job
                          .description}'),
                ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n?.translate('close') ?? 'Close'))
            ],
          ),
    );
  }

  (Color, String, IconData) _orderStatus(String s, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (s) {
      case 'delivered':
        return (
        Colors.green,
        l10n?.translate('delivered').toUpperCase() ?? 'DELIVERED',
        Icons.check_circle_rounded
        );
      case 'in_transit':
        return (
        Colors.blue,
        l10n?.translate('in_transit').toUpperCase() ?? 'IN TRANSIT',
        Icons.local_shipping_rounded
        );
      case 'confirmed':
        return (
        Colors.orange,
        l10n?.translate('confirmed').toUpperCase() ?? 'CONFIRMED',
        Icons.check_circle_outline
        );
      case 'rejected':
        return (
        Colors.red,
        l10n?.translate('rejected').toUpperCase() ?? 'REJECTED',
        Icons.cancel
        );
      case 'cancelled':
        return (
        Colors.red,
        l10n?.translate('cancelled').toUpperCase() ?? 'CANCELLED',
        Icons.cancel
        );
      default:
        return (
        Colors.orange,
        l10n?.translate('pending').toUpperCase() ?? 'PENDING',
        Icons.hourglass_empty_rounded
        );
    }
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(children: [
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
    ]);
  }

  Widget _buildProfileTab() {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
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
                colors: [Color(0xFF1B5E20), kGreen],
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
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle),
                child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text('👨‍🌾', style: TextStyle(fontSize: 38)))),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 12))
            ]),
            const SizedBox(height: 12),
            Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4))),
                child: Text('🌾  ${l10n?.translate('farmer') ?? 'Farmer'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _miniStatCard(
                  '${_products.length}',
                  l10n?.translate('products') ?? 'Products',
                  Icons.inventory_2_rounded,
                  kGreen,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStatCard(
                  '${_orders.length}',
                  l10n?.translate('orders') ?? 'Orders',
                  Icons.receipt_long_rounded,
                  kAmber,
                  cardColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStatCard(
                  '4.8 ⭐',
                  l10n?.translate('rating') ?? 'Rating',
                  Icons.star_rounded,
                  Colors.orange,
                  cardColor)),
        ]),
        const SizedBox(height: 20),
        _buildProfileTile(
            Icons.inventory_2_rounded,
            l10n?.translate('my_products') ?? 'My Products',
            '${_products.length} ${l10n?.translate('products') ?? 'products'}',
            kGreen,
            cardColor,
            onTap: () => setState(() => _selectedIndex = 1)),
        _buildProfileTile(
            Icons.receipt_long_rounded,
            l10n?.translate('my_orders') ?? 'My Orders',
            '${_orders.length} ${l10n?.translate('orders') ?? 'orders'}',
            Colors.blue.shade700,
            cardColor,
            onTap: () => setState(() => _selectedIndex = 2)),
        _buildProfileTile(
            Icons.work_outline,
            l10n?.translate('my_job_posts') ?? 'My Job Posts',
            '${_myJobs.length} ${l10n?.translate('active') ?? 'active'}',
            Colors.deepPurple,
            cardColor,
            onTap: () => setState(() => _selectedIndex = 3)),
        _buildProfileTile(
            Icons.brightness_6_rounded,
            l10n?.translate('dark_mode') ?? 'Dark Mode',
            themeProvider.isDarkMode
                ? (l10n?.translate('enabled') ?? 'Enabled')
                : (l10n?.translate('disabled') ?? 'Disabled'),
            Colors.purple,
            cardColor,
            onTap: () => themeProvider.toggleTheme()),
        _buildProfileTile(
            Icons.language_rounded,
            l10n?.translate('language') ?? 'Language',
            localeProvider.locale.languageCode == 'en'
                ? (l10n?.translate('english') ?? 'English')
                : (localeProvider.locale.languageCode == 'hi'
                ? (l10n?.translate('hindi') ?? 'Hindi')
                : (l10n?.translate('marathi') ?? 'Marathi')),
            Colors.teal,
            cardColor,
            onTap: () => _showLanguageDialog()),
        _buildProfileTile(
            Icons.edit_note_rounded,
            l10n?.translate('edit_profile') ?? 'Edit Profile',
            l10n?.translate('update_profile_desc') ??
                'Update your name & details',
            Colors.purple.shade400,
            cardColor,
            onTap: _showEditProfileDialog),
        _buildProfileTile(
            Icons.help_outline_rounded,
            l10n?.translate('help_support') ?? 'Help & Support',
            'support@krishilink.com',
            Colors.teal,
            cardColor,
            onTap: () =>
                _showInfoDialog(
                    l10n?.translate('help_support') ?? 'Help & Support',
                    '📞 ${l10n?.translate('helpline') ??
                        'Helpline'}: 1800-123-4567\n📧 ${l10n?.translate(
                        'email') ??
                        'Email'}: support@krishilink.com\n\nAvailable Mon–Sat, 8 AM – 8 PM')),
        _buildProfileTile(
            Icons.info_outline_rounded,
            l10n?.translate('about_app') ?? 'About KrishiLink',
            '${l10n?.translate('version') ?? 'Version'} 1.0.0',
            Colors.grey.shade600,
            cardColor,
            onTap: () =>
                _showInfoDialog(
                    l10n?.translate('about_app') ?? 'About KrishiLink',
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
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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

  Widget _miniStatCard(String value, String label, IconData icon, Color color,
      Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ]),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))
      ]),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle,
      Color color, Color cardColor,
      {required VoidCallback onTap}) {
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
        subtitle: Text(subtitle,
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
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: Text(l10n?.translate('logout') ?? 'Logout')),
            ],
          ),
    );
    if (confirm == true) _logout();
  }

  void _showInfoDialog(String title, String content) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Text(
                title, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(content),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen, foregroundColor: Colors.white),
                  child: Text(l10n?.translate('close') ?? 'Close'))
            ],
          ),
    );
  }

  void _showEditProfileDialog() {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: _userName);
    final locCtrl = TextEditingController(text: _userLocation);
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                      backgroundColor: kGreen, foregroundColor: Colors.white),
                  child: Text(l10n?.translate('save') ?? 'Save')),
            ],
          ),
    );
  }
}
