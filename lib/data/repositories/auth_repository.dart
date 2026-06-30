import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tahweela/data/models/public_users.dart';
import 'package:tahweela/firebase_options.dart';

import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<UserModel?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }

  Future<FirebaseApp> _secondaryApp() async {
    try {
      return Firebase.app('SecondaryApp');
    } catch (_) {
      return Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  Future<UserModel?> findUserByNationalId(String nationalId) async {
    final normalizedNationalId = _normalizeNationalId(nationalId);
    final snapshot = await _firestore
        .collection('users')
        .where('nationalID', isEqualTo: normalizedNationalId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(snapshot.docs.first);
  }

  Future<UserModel> createLinkedUserFromPublicUser({
    required PublicUserModel publicUser,
    required String role,
    required String phone,
    String? specialty,
    String? password,
  }) async {
    final nationalId = _normalizeNationalId(publicUser.nationalId);
    final existingUser = await findUserByNationalId(nationalId);
    final email = '$nationalId@tahweela.com';
    final secondaryAuth = FirebaseAuth.instanceFor(app: await _secondaryApp());
    UserCredential userCredential;

    try {
      userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: _normalizePassword(password ?? nationalId),
      );
    } on FirebaseAuthException catch (error) {
      await secondaryAuth.signOut();
      if (error.code == 'email-already-in-use' && existingUser != null) {
        await _markPublicUserLinked(
          publicUser: publicUser,
          user: existingUser,
          role: role,
        );
        return existingUser;
      }
      rethrow;
    }

    final user = UserModel(
      uid: userCredential.user!.uid,
      email: email,
      nationalID: nationalId,
      name: publicUser.fullName,
      phone: phone,
      role: role,
      specialty: role == 'doctor' ? specialty : null,
      publicUserId: publicUser.publicUserId,
      gender: publicUser.gender,
      age: publicUser.age,
      createdAt: existingUser?.createdAt,
    );

    try {
      final batch = _firestore.batch();
      batch.set(_firestore.collection('users').doc(user.uid), user.toMap());
      if (existingUser != null && existingUser.uid != user.uid) {
        batch.delete(_firestore.collection('users').doc(existingUser.uid));
      }
      batch.update(
        _firestore.collection('public_users').doc(publicUser.documentId),
        {
          'is_linked': true,
          'app_user_uid': user.uid,
          'linked_role': role,
          'linked_at': FieldValue.serverTimestamp(),
        },
      );
      await batch.commit();
    } catch (_) {
      await userCredential.user?.delete();
      rethrow;
    } finally {
      await secondaryAuth.signOut();
    }

    return user;
  }

  Future<void> _markPublicUserLinked({
    required PublicUserModel publicUser,
    required UserModel user,
    required String role,
  }) async {
    await _firestore.collection('public_users').doc(publicUser.documentId).set({
      'is_linked': true,
      'app_user_uid': user.uid,
      'linked_role': role,
      'linked_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> registerSecondaryUser(UserModel user, String password) async {
    final secondaryAuth = FirebaseAuth.instanceFor(app: await _secondaryApp());
    final nationalId = _normalizeNationalId(user.nationalID);
    final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
      email: '$nationalId@tahweela.com',
      password: _normalizePassword(password),
    );

    final createdUser = UserModel(
      uid: userCredential.user!.uid,
      nationalID: nationalId,
      email: '$nationalId@tahweela.com',
      name: user.name,
      phone: user.phone,
      role: user.role,
      specialty: user.specialty,
      publicUserId: user.publicUserId,
      gender: user.gender,
      age: user.age,
      createdAt: user.createdAt,
    );

    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(createdUser.toMap());
    await secondaryAuth.signOut();
  }

  String _normalizeNationalId(String value) {
    return value.trim().replaceAll(RegExp(r'[\s-]+'), '').replaceAllMapped(
      RegExp(r'[٠-٩۰-۹]'),
      (match) {
        const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
        const persianDigits = '۰۱۲۳۴۵۶۷۸۹';
        final digit = match.group(0)!;
        final arabicIndex = arabicDigits.indexOf(digit);
        if (arabicIndex != -1) return arabicIndex.toString();
        return persianDigits.indexOf(digit).toString();
      },
    );
  }

  String _normalizePassword(String value) {
    return _normalizeNationalId(value);
  }
}
