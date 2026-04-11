import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../utils/app_localizations.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _search = '';
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Spices'
  ];
  final List<Map<String, dynamic>> _cart = [];
  List<ProductModel> _products = [];
  String _buyerUid = '';
  String _buyerName = '';
  String _buyerLocation = 'India';
  bool _isProcessing = false;

  static const Map<String, String> _emojiMap = {
    'tomato': '🍅',
    'potato': '🥔',
    'chilli': '🌶️',
    'onion': '🧅',
    'spinach': '🥬',
    'carrot': '🥕',
    'mango': '🥭',
    'banana': '🍌',
    'wheat': '🌾',
    'rice': '🌾',
  };

  String _emoji(String name) {
    final lower = name.toLowerCase();
    for (final e in _emojiMap.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return '🥬';
  }

  List<ProductModel> get _filtered {
    return _products.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.name.contains(_selectedCategory);
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.farmerName.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch && p.status == 'available';
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _listenToProducts();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _buyerUid = prefs.getString('userUid') ?? '';
      _buyerLocation = prefs.getString('userLocation') ?? 'India';
      _buyerName = prefs.getString('userName') ?? 'Buyer';
    });
  }

  void _listenToProducts() {
    FirestoreService().streamProducts().listen((products) {
      if (mounted) setState(() => _products = products);
    });
  }

  int _cartQty(String productDocId) {
    final item = _cart.where((c) => c['docId'] == productDocId).firstOrNull;
    return item?['qty'] ?? 0;
  }

  void _addToCart(ProductModel product) {
    setState(() {
      final idx = _cart.indexWhere((c) => c['docId'] == product.docId);
      if (idx >= 0) {
        _cart[idx]['qty'] = (_cart[idx]['qty'] as int) + 1;
      } else {
        _cart.add({
          'docId': product.docId,
          'name': product.name,
          'price': product.price,
          'unit': product.unit,
          'farmerUid': product.farmerUid,
          'farmerId': product.farmerId,
          'farmerName': product.farmerName,
          'qty': 1,
        });
      }
    });
  }

  void _removeFromCart(String productDocId) {
    setState(() {
      final idx = _cart.indexWhere((c) => c['docId'] == productDocId);
      if (idx >= 0) {
        if ((_cart[idx]['qty'] as int) > 1) {
          _cart[idx]['qty'] = (_cart[idx]['qty'] as int) - 1;
        } else {
          _cart.removeAt(idx);
        }
      }
    });
  }

  int get _totalCartItems => _cart.fold(0, (s, c) => s + (c['qty'] as int));

  double get _totalCartAmount => _cart.fold(
      0.0, (s, c) => s + ((c['price'] as double) * (c['qty'] as int)));

  Future<String?> _showPaymentMethodDialog() async {
    final l10n = AppLocalizations.of(context);
    String? selected = 'cod';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n?.translate('select_payment_method') ??
            'Select Payment Method'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(
                    l10n?.translate('cash_on_delivery') ?? 'Cash on Delivery'),
                value: 'cod',
                groupValue: selected,
                onChanged: (val) => setStateDialog(() => selected = val!),
              ),
              RadioListTile<String>(
                title: Text(l10n?.translate('upi_method') ??
                    'UPI (PhonePe / Google Pay)'),
                value: 'upi',
                groupValue: selected,
                onChanged: (val) => setStateDialog(() => selected = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(l10n?.translate('cancel') ?? 'Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(l10n?.translate('continue') ?? 'Continue')),
        ],
      ),
    );
  }

  Future<String?> _showUpiDialog() async {
    final l10n = AppLocalizations.of(context);
    final upiController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n?.translate('enter_upi_id') ?? 'Enter UPI ID'),
        content: TextField(
          controller: upiController,
          decoration: const InputDecoration(
              hintText: 'example@okhdfcbank', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(l10n?.translate('cancel') ?? 'Cancel')),
          ElevatedButton(
            onPressed: () {
              final upi = upiController.text.trim();
              if (upi.isNotEmpty) {
                Navigator.pop(context, upi);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n?.translate('please_enter_upi_id') ??
                          'Please enter UPI ID'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: Text(l10n?.translate('send_request') ?? 'Send Request'),
          ),
        ],
      ),
    );
  }

  Future<bool> _fakeUpiRequest(String upiId) async {
    final l10n = AppLocalizations.of(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${l10n?.translate('sending_request_to') ?? 'Sending request to'} $upiId...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1)),
      );
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n?.translate('payment_request_sent') ??
                'Payment request sent successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1)),
      );
    }
    return true;
  }

  Future<void> _placeOrder(String? paymentMethod, String? upiId) async {
    if (_cart.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final buyerLocation = prefs.getString('userLocation') ?? 'India';

    for (var item in _cart) {
      final order = OrderModel(
        id: 0,
        productDocId: item['docId'] ?? '',
        productName: item['name'],
        buyerUid: _buyerUid,
        buyerId: 0,
        buyerName: _buyerName,
        buyerPhone: '',
        farmerUid: item['farmerUid'] ?? '',
        farmerId: item['farmerId'] ?? 0,
        farmerName: item['farmerName'],
        farmerPhone: '',
        quantity: (item['qty'] as int).toDouble(),
        unit: item['unit'],
        price: (item['price'] as double),
        totalAmount: (item['price'] as double) * (item['qty'] as int),
        status: 'pending',
        trackingStatus: 'harvested',
        orderDate: DateTime.now(),
        deliveredDate: null,
        deliveryAddress: buyerLocation,
        farmerLocation: null,
        paymentMethod: paymentMethod,
        upiId: upiId,
      );
      await FirestoreService().placeOrder(
          order, _buyerUid, item['farmerUid'] ?? '',
          paymentMethod: paymentMethod, upiId: upiId);
    }
    setState(() => _cart.clear());
  }

  Future<void> _proceedToPayment() async {
    final l10n = AppLocalizations.of(context);
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final paymentMethod = await _showPaymentMethodDialog();
      if (paymentMethod == null) {
        setState(() => _isProcessing = false);
        return;
      }

      String? upiId;
      if (paymentMethod == 'upi') {
        upiId = await _showUpiDialog();
        if (upiId == null || upiId.trim().isEmpty) {
          setState(() => _isProcessing = false);
          return;
        }
        final success = await _fakeUpiRequest(upiId);
        if (!success) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      await _placeOrder(paymentMethod, upiId);
      Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n?.translate('order_placed_successfully') ??
                  'Order placed successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${l10n?.translate('error_prefix') ?? 'Error'}: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showCart() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${l10n?.translate('marketplace') ?? 'Cart'} 🛒',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('₹${_totalCartAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ]),
              ),
              const Divider(),
              if (_cart.isEmpty)
                const Expanded(
                    child: Center(
                        child: Text('🛒',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 40))))
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _cart.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = _cart[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        leading: Text(_emoji(item['name']),
                            style: const TextStyle(fontSize: 28)),
                        title: Text(item['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('₹${item['price']}/${item['unit']}'),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          _qtyBtn(Icons.remove_rounded, () {
                            setState(
                                () => _removeFromCart(item['docId'] ?? ''));
                            setSheet(() {});
                          }),
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('${item['qty']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          _qtyBtn(Icons.add_rounded, () {
                            setState(() => _addToCart(_products
                                .firstWhere((p) => p.docId == item['docId'])));
                            setSheet(() {});
                          }),
                        ]),
                      );
                    },
                  ),
                ),
              if (_cart.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _proceedToPayment,
                            icon: const Icon(Icons.payment_rounded,
                                color: Colors.white),
                            label: Text(
                                '${l10n?.translate('proceed_to_payment') ?? 'Proceed to Payment'} · ₹${_totalCartAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F0),
      appBar: AppBar(
        title: Text('${l10n?.translate('marketplace') ?? 'Marketplace'} 🌾',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                  icon: const Icon(Icons.shopping_cart_rounded),
                  onPressed: _showCart),
              if (_totalCartItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('$_totalCartItems',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF2E7D32),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l10n?.translate('search_products') ??
                        'Search produce...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            cat == 'All'
                                ? (l10n?.translate('all') ?? 'All')
                                : cat,
                            style: TextStyle(
                                color: selected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.white,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                        l10n?.translate('no_products') ?? 'No products found',
                        style: const TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      final qty = _cartQty(p.docId);
                      final cardColor =
                          isDark ? const Color(0xFF2A2A2A) : Colors.white;
                      return Container(
                        decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Column(
                          children: [
                            Container(
                                height: 90,
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1B2E1B)
                                        : const Color(0xFFF1F8E9),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16))),
                                child: Center(
                                    child: Text(_emoji(p.name),
                                        style: const TextStyle(fontSize: 44)))),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${l10n?.translate('by') ?? 'by'} ${p.farmerName}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Text('₹${p.price}/${p.unit}',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32))),
                                      const Spacer(),
                                      Row(children: [
                                        const Icon(Icons.star_rounded,
                                            size: 12, color: Colors.amber),
                                        Text('${p.rating ?? 4.5}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey))
                                      ]),
                                    ]),
                                    const SizedBox(height: 8),
                                    if (qty == 0)
                                      SizedBox(
                                        width: double.infinity,
                                        height: 34,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _addToCart(p),
                                          icon: const Icon(
                                              Icons.add_shopping_cart_rounded,
                                              size: 14,
                                              color: Colors.white),
                                          label: Text(
                                              l10n?.translate('add') ?? 'Add',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2E7D32),
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      )
                                    else
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _qtyBtn(Icons.remove_rounded,
                                                () => _removeFromCart(p.docId)),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                child: Text('$qty',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16))),
                                            _qtyBtn(Icons.add_rounded,
                                                () => _addToCart(p)),
                                          ]),
                                  ]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _totalCartItems > 0
          ? FloatingActionButton.extended(
              onPressed: _showCart,
              backgroundColor: const Color(0xFF2E7D32),
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text('₹${_totalCartAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)))
          : null,
    );
  }
}
