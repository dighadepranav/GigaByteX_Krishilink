import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String docId;
  final int id;
  final String productDocId;
  final String productName;
  final String buyerUid;
  final int buyerId;
  final String buyerName;
  final String buyerPhone;
  final String farmerUid;
  final int farmerId;
  final String farmerName;
  final String farmerPhone;
  final double quantity;
  final String unit;
  final double price;
  final double totalAmount;
  final String status; // pending | confirmed | rejected | delivered | cancelled
  final String
      trackingStatus; // harvested | packed | in_transit | out_for_delivery | delivered
  final DateTime orderDate;
  final DateTime? deliveredDate;
  final String? deliveryAddress; // buyer's location (city)
  final String? farmerLocation; // farmer's location (city)
  final String? paymentMethod; // 'cod' or 'upi'
  final String? upiId; // UPI ID if paymentMethod == 'upi'

  OrderModel({
    this.docId = '',
    required this.id,
    this.productDocId = '',
    required this.productName,
    this.buyerUid = '',
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    this.farmerUid = '',
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.trackingStatus,
    required this.orderDate,
    this.deliveredDate,
    this.deliveryAddress,
    this.farmerLocation,
    this.paymentMethod,
    this.upiId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return OrderModel(
      docId: doc.id,
      id: json['id'] ?? 0,
      productDocId: json['productDocId'] ?? '',
      productName: json['product_name'] ?? 'Product',
      buyerUid: json['buyerUid'] ?? '',
      buyerId: json['buyer_id'] ?? 0,
      buyerName: json['buyer_name'] ?? 'Buyer',
      buyerPhone: json['buyerPhone'] ?? '',
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      farmerPhone: json['farmerPhone'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      trackingStatus: json['trackingStatus'] ?? 'harvested',
      orderDate: (json['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredDate: (json['deliveredDate'] as Timestamp?)?.toDate(),
      deliveryAddress: json['deliveryAddress'],
      farmerLocation: json['farmerLocation'],
      paymentMethod: json['paymentMethod'],
      upiId: json['upiId'],
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      docId: json['docId'] ?? '',
      id: json['id'] ?? 0,
      productDocId: json['productDocId'] ?? '',
      productName: json['product_name'] ?? 'Product',
      buyerUid: json['buyerUid'] ?? '',
      buyerId: json['buyer_id'] ?? 0,
      buyerName: json['buyer_name'] ?? 'Buyer',
      buyerPhone: json['buyerPhone'] ?? '',
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      farmerPhone: json['farmerPhone'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      trackingStatus: json['trackingStatus'] ?? 'harvested',
      orderDate: json['orderDate'] is Timestamp
          ? (json['orderDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      deliveredDate: json['deliveredDate'] is Timestamp
          ? (json['deliveredDate'] as Timestamp).toDate()
          : null,
      deliveryAddress: json['deliveryAddress'],
      farmerLocation: json['farmerLocation'],
      paymentMethod: json['paymentMethod'],
      upiId: json['upiId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'productDocId': productDocId,
      'product_name': productName,
      'buyerUid': buyerUid,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'buyerPhone': buyerPhone,
      'farmerUid': farmerUid,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmerPhone': farmerPhone,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'totalAmount': totalAmount,
      'status': status,
      'trackingStatus': trackingStatus,
      'deliveryAddress': deliveryAddress,
      'farmerLocation': farmerLocation,
      'paymentMethod': paymentMethod,
      'upiId': upiId,
    };
  }

  Map<String, dynamic> toJson() => toFirestore();

  OrderModel copyWith({
    String? docId,
    int? id,
    String? productDocId,
    String? productName,
    String? buyerUid,
    int? buyerId,
    String? buyerName,
    String? buyerPhone,
    String? farmerUid,
    int? farmerId,
    String? farmerName,
    String? farmerPhone,
    double? quantity,
    String? unit,
    double? price,
    double? totalAmount,
    String? status,
    String? trackingStatus,
    DateTime? orderDate,
    DateTime? deliveredDate,
    String? deliveryAddress,
    String? farmerLocation,
    String? paymentMethod,
    String? upiId,
  }) {
    return OrderModel(
      docId: docId ?? this.docId,
      id: id ?? this.id,
      productDocId: productDocId ?? this.productDocId,
      productName: productName ?? this.productName,
      buyerUid: buyerUid ?? this.buyerUid,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      farmerUid: farmerUid ?? this.farmerUid,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      trackingStatus: trackingStatus ?? this.trackingStatus,
      orderDate: orderDate ?? this.orderDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      farmerLocation: farmerLocation ?? this.farmerLocation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      upiId: upiId ?? this.upiId,
    );
  }

  bool get isPending => status == 'pending';

  bool get isConfirmed => status == 'confirmed';

  bool get isRejected => status == 'rejected';

  bool get isCancelled => status == 'cancelled';

  bool get isDelivered => status == 'delivered';

  String get trackingLabel {
    switch (trackingStatus) {
      case 'harvested':
        return 'Harvested';
      case 'packed':
        return 'Packed';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return 'Processing';
    }
  }

  String get paymentMethodLabel {
    if (paymentMethod == 'upi') return 'UPI (${upiId ?? "N/A"})';
    return 'Cash on Delivery';
  }
}
