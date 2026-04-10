class OrderModel {
  final String docId;
  final int id;
  final String productDocId;
  final String productName;
  final String buyerUid;
  final int buyerId;
  final String buyerName;
  final String farmerUid;
  final int farmerId;
  final String farmerName;
  final double quantity;
  final String unit;
  final double price;
  final double totalAmount;
  final String status;
  final String trackingStatus;
  final DateTime orderDate;
  final DateTime? deliveredDate;
  final String? deliveryAddress;

  OrderModel({
    this.docId = '',
    required this.id,
    this.productDocId = '',
    required this.productName,
    this.buyerUid = '',
    required this.buyerId,
    required this.buyerName,
    this.farmerUid = '',
    required this.farmerId,
    required this.farmerName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.totalAmount,
    required this.status,
    required this.trackingStatus,
    required this.orderDate,
    this.deliveredDate,
    this.deliveryAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      docId: json['docId'] ?? '',
      id: json['id'] ?? 0,
      productDocId: json['productDocId'] ?? '',
      productName: json['product_name'] ?? 'Product',
      buyerUid: json['buyerUid'] ?? '',
      buyerId: json['buyer_id'] ?? 0,
      buyerName: json['buyer_name'] ?? 'Buyer',
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      trackingStatus: json['trackingStatus'] ?? 'harvested',
      orderDate: DateTime.tryParse(json['order_date'] ?? '') ?? DateTime.now(),
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.tryParse(json['deliveredDate'])
          : null,
      deliveryAddress: json['deliveryAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productDocId': productDocId,
      'product_name': productName,
      'buyerUid': buyerUid,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'farmerUid': farmerUid,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'totalAmount': totalAmount,
      'status': status,
      'trackingStatus': trackingStatus,
      'deliveryAddress': deliveryAddress,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isDelivered => status == 'delivered';
}
