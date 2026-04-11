import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/job_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== PRODUCTS ====================
  Stream<List<ProductModel>> streamProducts() {
    return _db
        .collection('products')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => ProductModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ProductModel>> streamFarmerProducts(String farmerUid) {
    return _db
        .collection('products')
        .where('farmerUid', isEqualTo: farmerUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => ProductModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addProduct(ProductModel product, String farmerUid) async {
    final ref = _db.collection('products').doc();
    await ref.set({
      ...product.toFirestore(),
      'docId': ref.id,
      'farmerUid': farmerUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.docId).update(product.toFirestore());
  }

  Future<void> deleteProduct(String docId) async {
    await _db.collection('products').doc(docId).delete();
  }

  // ==================== ORDERS ====================
  Stream<List<OrderModel>> streamBuyerOrders(String buyerUid) {
    return _db
        .collection('orders')
        .where('buyerUid', isEqualTo: buyerUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => OrderModel.fromFirestore(d)).toList();
      list.sort((a, b) {
        final aDate = a.orderDate ?? DateTime(2000);
        final bDate = b.orderDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return list;
    });
  }

  Stream<List<OrderModel>> streamFarmerOrders(String farmerUid) {
    return _db
        .collection('orders')
        .where('farmerUid', isEqualTo: farmerUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => OrderModel.fromFirestore(d)).toList();
      list.sort((a, b) {
        final aDate = a.orderDate ?? DateTime(2000);
        final bDate = b.orderDate ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return list;
    });
  }

  Future<String> placeOrder(
      OrderModel order, String buyerUid, String farmerUid,
      {String? paymentMethod, String? upiId}) async {
    final ref = _db.collection('orders').doc();
    await ref.set({
      ...order.toFirestore(),
      'docId': ref.id,
      'buyerUid': buyerUid,
      'farmerUid': farmerUid,
      'orderDate': FieldValue.serverTimestamp(),
      'paymentMethod': paymentMethod,
      'upiId': upiId,
    });
    return ref.id;
  }

  Future<void> updateOrderStatus(String docId, String status, String trackingStatus) async {
    final Map<String, dynamic> update = {
      'status': status,
      'trackingStatus': trackingStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == 'delivered') {
      update['deliveredDate'] = FieldValue.serverTimestamp();
    }
    await _db.collection('orders').doc(docId).update(update);
  }

  // ==================== JOBS ====================
  Stream<List<JobModel>> streamOpenJobs() {
    return _db
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => JobModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<JobModel>> streamFarmerJobs(String farmerUid) {
    return _db
        .collection('jobs')
        .where('farmerUid', isEqualTo: farmerUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => JobModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> addJob(JobModel job, String farmerUid) async {
    final ref = _db.collection('jobs').doc();
    await ref.set({
      ...job.toFirestore(),
      'docId': ref.id,
      'farmerUid': farmerUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> applyForJob({
    required String jobDocId,
    required String workerUid,
    required String workerName,
    required String workerPhone,
  }) async {
    final existing = await _db
        .collection('jobApplications')
        .where('jobDocId', isEqualTo: jobDocId)
        .where('workerUid', isEqualTo: workerUid)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('You have already applied for this job.');
    }
    await _db.collection('jobApplications').add({
      'jobDocId': jobDocId,
      'workerUid': workerUid,
      'workerName': workerName,
      'workerPhone': workerPhone,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamJobApplications(String jobDocId) {
    return _db
        .collection('jobApplications')
        .where('jobDocId', isEqualTo: jobDocId)
        .snapshots()
        .map((s) => s.docs.map((d) {
      final data = d.data();
      return {
        'docId': d.id,
        'workerName': data['workerName'] ?? 'Worker',
        'workerPhone': data['workerPhone'] ?? '',
        'status': data['status'] ?? 'pending',
        'appliedAt': data['appliedAt'],
      };
    }).toList());
  }

  Future<void> updateApplicationStatus(String appDocId, String status) async {
    await _db.collection('jobApplications').doc(appDocId).update({'status': status});
  }

  Stream<Set<String>> streamUserApplications(String workerUid) {
    return _db
        .collection('jobApplications')
        .where('workerUid', isEqualTo: workerUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['jobDocId'] as String).toSet());
  }

  // ==================== USERS ====================
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  Future<void> updateUserLocation(String uid, String location) async {
    await _db.collection('users').doc(uid).update({'location': location});
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== ADMIN STATS ====================
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final usersSnap = await _db.collection('users').get();
      int farmers = 0, buyers = 0, workers = 0;
      for (final doc in usersSnap.docs) {
        final role = (doc.data()['role'] ?? '') as String;
        if (role == 'farmer') farmers++;
        if (role == 'buyer') buyers++;
        if (role == 'worker') workers++;
      }

      final ordersSnap = await _db.collection('orders').get();
      int totalOrders = ordersSnap.docs.length;

      final openJobsSnap = await _db.collection('jobs').where('status', isEqualTo: 'open').get();
      int openJobs = openJobsSnap.docs.length;

      double revenue = 0;
      for (final doc in ordersSnap.docs) {
        if ((doc.data()['status'] ?? '') == 'delivered') {
          revenue += ((doc.data()['totalAmount'] ?? 0) as num).toDouble();
        }
      }

      return {
        'farmers': farmers,
        'buyers': buyers,
        'workers': workers,
        'orders': totalOrders,
        'open_jobs': openJobs,
        'total_value': revenue,
      };
    } catch (e) {
      return {'farmers': 0, 'buyers': 0, 'workers': 0, 'orders': 0, 'open_jobs': 0, 'total_value': 0.0};
    }
  }
}