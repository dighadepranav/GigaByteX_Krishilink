import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String docId;
  final int id;
  final String farmerUid;
  final int farmerId;
  final String farmerName;
  final String title;
  final String description;
  final String location;
  final double wage;
  final String duration;
  final int workersNeeded;
  final String status;
  final DateTime createdAt;
  final int? applicationsCount;
  final bool isSaved;
  final bool isApplied;

  JobModel({
    this.docId = '',
    required this.id,
    this.farmerUid = '',
    required this.farmerId,
    required this.farmerName,
    required this.title,
    required this.description,
    required this.location,
    required this.wage,
    required this.duration,
    required this.workersNeeded,
    required this.status,
    required this.createdAt,
    this.applicationsCount,
    this.isSaved = false,
    this.isApplied = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      docId: json['docId'] ?? '',
      id: json['id'] ?? 0,
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      wage: (json['wage'] ?? 0).toDouble(),
      duration: json['duration'] ?? '1 day',
      workersNeeded: json['workers_needed'] ?? 1,
      status: json['status'] ?? 'open',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      applicationsCount: json['applications_count'],
      isSaved: json['is_saved'] ?? false,
      isApplied: json['has_applied'] ?? false,
    );
  }

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return JobModel(
      docId: doc.id,
      id: json['id'] ?? 0,
      farmerUid: json['farmerUid'] ?? '',
      farmerId: json['farmer_id'] ?? 0,
      farmerName: json['farmer_name'] ?? 'Farmer',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      wage: (json['wage'] ?? 0).toDouble(),
      duration: json['duration'] ?? '1 day',
      workersNeeded: json['workers_needed'] ?? 1,
      status: json['status'] ?? 'open',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicationsCount: json['applications_count'],
      isSaved: json['is_saved'] ?? false,
      isApplied: json['has_applied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'title': title,
      'description': description,
      'location': location,
      'wage': wage,
      'duration': duration,
      'workers_needed': workersNeeded,
      'status': status,
      'applications_count': applicationsCount ?? 0,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'title': title,
      'description': description,
      'location': location,
      'wage': wage,
      'duration': duration,
      'workers_needed': workersNeeded,
      'status': status,
      'applications_count': applicationsCount ?? 0,
    };
  }

  JobModel copyWith({
    String? docId,
    int? id,
    String? farmerUid,
    int? farmerId,
    String? farmerName,
    String? title,
    String? description,
    String? location,
    double? wage,
    String? duration,
    int? workersNeeded,
    String? status,
    DateTime? createdAt,
    int? applicationsCount,
    bool? isSaved,
    bool? isApplied,
  }) {
    return JobModel(
      docId: docId ?? this.docId,
      id: id ?? this.id,
      farmerUid: farmerUid ?? this.farmerUid,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      wage: wage ?? this.wage,
      duration: duration ?? this.duration,
      workersNeeded: workersNeeded ?? this.workersNeeded,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  bool get isOpen => status == 'open';
  String get formattedWage => '₹${wage.toStringAsFixed(0)}/day';
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'just now';
  }
}
