class UserModel {
  final int id;
  final String phone;
  final String name;
  final String role;
  final String location;
  final String? profileImage;
  final DateTime createdAt;
  final double? rating;
  final int? totalOrders;
  final double? totalEarned;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.location,
    this.profileImage,
    required this.createdAt,
    this.rating,
    this.totalOrders,
    this.totalEarned,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? 0) as int,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'farmer',
      location: json['location'] ?? '',
      profileImage: json['profile_image'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalOrders: json['total_orders'] as int?,
      totalEarned: (json['total_earned'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role,
      'location': location,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'rating': rating,
      'total_orders': totalOrders,
      'total_earned': totalEarned,
    };
  }

  bool get isFarmer => role == 'farmer';
  bool get isBuyer => role == 'buyer';
  bool get isWorker => role == 'worker';
  bool get isAdmin => role == 'admin';
}
