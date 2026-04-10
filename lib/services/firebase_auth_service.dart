import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ConfirmationResult? _webConfirmation;

  Future<void> sendOtp(
      String phone, {
        required void Function(String verificationId) onCodeSent,
        required void Function(String error) onError,
      }) async {
    final fullPhone = '+91$phone';

    if (kIsWeb) {
      try {
        _webConfirmation = await _auth.signInWithPhoneNumber(fullPhone);
        onCodeSent('web');
      } on FirebaseAuthException catch (e) {
        onError(_friendlyError(e));
      } catch (e) {
        onError(e.toString());
      }
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (_) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_friendlyError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    }
  }

  Future<UserModel?> verifyOtp({
    required String verificationId,
    required String otp,
    required String role,
    required String name,
  }) async {
    UserCredential cred;

    if (kIsWeb) {
      if (_webConfirmation == null) {
        throw Exception('Please request OTP first.');
      }
      cred = await _webConfirmation!.confirm(otp);
    } else {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      cred = await _auth.signInWithCredential(credential);
    }

    final user = cred.user!;
    final uid = user.uid;
    final phone = user.phoneNumber ?? '+91Unknown';

    final docId = '${uid}_$role';
    final docSnap = await _db.collection('users').doc(docId).get();

    if (docSnap.exists) {
      return UserModel.fromJson(docSnap.data()!);
    } else {
      final numericId = docId.hashCode.abs() & 0x7FFFFFFF;
      final newUser = UserModel(
        id: numericId,
        phone: phone,
        name: name,
        role: role,
        location: '',
        createdAt: DateTime.now(),
      );
      final data = newUser.toJson();
      data['docId'] = docId;
      data['uid'] = uid;
      await _db.collection('users').doc(docId).set(data);
      return newUser;
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Phone number is not valid.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try tomorrow.';
      case 'invalid-verification-code':
        return 'Wrong OTP. Please check.';
      case 'session-expired':
        return 'OTP expired. Request new one.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}