import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String docId;
  final int id;
  final String farmerUid;
  final int farmerId;
  final String farmerName;
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final double marketPrice;
  final String? description;
  final List<String>? images;
  final String status;
  final DateTime createdAt;
  final double? rating;
  final int? totalSold;

  ProductModel({
    this.docId = '',
    required this.id,
    this.farmerUid = '',
    required this.farmerId,
    required this.farmerName,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.marketPrice,
    this.description,
    this.images,
    required this.status,
    required this.createdAt,
    this.rating,
    this.totalSold,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      docId: json['docId'] ?? '',
      id: json['id'] ?? 0,
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: json['status'] ?? 'available',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      rating: json['rating']?.toDouble(),
      totalSold: json['total_sold'],
    );
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return ProductModel(
      docId: doc.id,
      id: json['id'] ?? 0,
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      status: json['status'] ?? 'available',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: json['rating']?.toDouble(),
      totalSold: json['total_sold'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'market_price': marketPrice,
      'description': description,
      'images': images,
      'status': status,
      'rating': rating,
      'total_sold': totalSold,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'market_price': marketPrice,
      'description': description,
      'images': images,
      'status': status,
      'rating': rating,
      'total_sold': totalSold,
    };
  }

  ProductModel copyWith({
    String? docId,
    int? id,
    String? farmerUid,
    int? farmerId,
    String? farmerName,
    String? name,
    double? quantity,
    String? unit,
    double? price,
    double? marketPrice,
    String? description,
    List<String>? images,
    String? status,
    DateTime? createdAt,
    double? rating,
    int? totalSold,
  }) {
    return ProductModel(
      docId: docId ?? this.docId,
      id: id ?? this.id,
      farmerUid: farmerUid ?? this.farmerUid,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      marketPrice: marketPrice ?? this.marketPrice,
      description: description ?? this.description,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      totalSold: totalSold ?? this.totalSold,
    );
  }

  double get savings => marketPrice - price;

  double get savingsPercentage =>
      marketPrice > 0 ? ((marketPrice - price) / marketPrice * 100) : 0;

  bool get isAvailable => status == 'available';
}
