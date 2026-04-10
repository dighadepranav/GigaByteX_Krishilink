import 'package:flutter/material.dart';
import '../models/product_model.dart';

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
      rating: 4.5,
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
      rating: 4.8,
    ),
    ProductModel(
      id: 3,
      farmerId: 2,
      farmerName: 'Suresh Yadav',
      name: 'Organic Onions',
      quantity: 200,
      unit: 'kg',
      price: 20,
      marketPrice: 35,
      status: 'available',
      createdAt: DateTime.now(),
      rating: 4.2,
    ),
    ProductModel(
      id: 4,
      farmerId: 2,
      farmerName: 'Suresh Yadav',
      name: 'Fresh Potatoes',
      quantity: 150,
      unit: 'kg',
      price: 18,
      marketPrice: 30,
      status: 'available',
      createdAt: DateTime.now(),
      rating: 4.6,
    ),
    ProductModel(
      id: 5,
      farmerId: 3,
      farmerName: 'Anita Deshmukh',
      name: 'Spinach',
      quantity: 30,
      unit: 'kg',
      price: 15,
      marketPrice: 25,
      status: 'available',
      createdAt: DateTime.now(),
      rating: 4.9,
    ),
  ];

  static const Map<String, String> _emojiMap = {
    'tomato': '🍅',
    'chilli': '🌶️',
    'onion': '🧅',
    'potato': '🥔',
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

  @override
  void initState() {
    super.initState();
    _products = _demoProducts;
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

  void _showCart() {
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
                    borderRadius: BorderRadius.circular(4)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cart 🛒',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹${_totalCartAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                      fontSize: 16)),
                            ),
                            _qtyBtn(Icons.add_rounded, () {
                              setState(() => _addToCart(_products.firstWhere(
                                  (p) => p.docId == item['docId'])));
                              setSheet(() {});
                            }),
                          ],
                        ),
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Order placed successfully!'),
                              backgroundColor: Colors.green),
                        );
                        setState(() => _cart.clear());
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_bag_rounded,
                          color: Colors.white),
                      label: Text(
                          'Confirm · ₹${_totalCartAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
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
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F0),
      appBar: AppBar(
        title: const Text('Marketplace 🌾',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    hintText: 'Search produce...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white60),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
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
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.white,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
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
                ? const Center(
                    child: Text('No products found',
                        style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
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
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 90,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1B2E1B)
                                    : const Color(0xFFF1F8E9),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                              ),
                              child: Center(
                                  child: Text(_emoji(p.name),
                                      style: const TextStyle(fontSize: 44))),
                            ),
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
                                  Text('by ${p.farmerName}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('₹${p.price}/${p.unit}',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32))),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 12, color: Colors.amber),
                                          Text('${p.rating ?? 4.5}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                        label: const Text('Add',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2E7D32),
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text('$qty',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        _qtyBtn(Icons.add_rounded,
                                            () => _addToCart(p)),
                                      ],
                                    ),
                                ],
                              ),
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
              foregroundColor: Colors.white,
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text('₹${_totalCartAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            )
          : null,
    );
  }
}
