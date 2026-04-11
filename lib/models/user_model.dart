import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Handle createdAt as Timestamp, ISO string, or missing
    DateTime createdAt;
    final raw = json['created_at'] ?? json['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String && raw.isNotEmpty) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: (json['id'] ?? 0) as int,
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'farmer',
      location: json['location'] ?? '',
      profileImage: json['profile_image'],
      createdAt: createdAt,
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

  UserModel copyWith({
    int? id,
    String? phone,
    String? name,
    String? role,
    String? location,
    String? profileImage,
    DateTime? createdAt,
    double? rating,
    int? totalOrders,
    double? totalEarned,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      location: location ?? this.location,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalEarned: totalEarned ?? this.totalEarned,
    );
  }

  bool get isFarmer => role == 'farmer';

  bool get isBuyer => role == 'buyer';

  bool get isWorker => role == 'worker';

  bool get isAdmin => role == 'admin';
}
