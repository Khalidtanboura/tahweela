import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tahweela/data/models/user_model.dart'
    hide UserModel; // ← استيراد حزمي نظيف وموحد
import 'package:tahweela/data/repositories/auth_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tahweela/data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// هذا المزود الآن يعيد Stream<UserModel?> بدلاً من الخريطة الخام
final userDataProvider = StreamProvider<UserModel?>((ref) {
  return FirebaseAuth.instance.authStateChanges().switchMap((user) {
    if (user == null) return Stream.value(null);
    // عند تغير حالة المستخدم، نعود لنقرأ بياناته من Firestore
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  });
});
