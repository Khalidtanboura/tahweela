import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tahweela/firebase_options.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> streamUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      // هنا يتم التحويل السحري من Map إلى Model محمي ومضمون الأنواع
      return UserModel.fromFirestore(snapshot);
    });
  }

  // إضافة مستخدم جديد دون طرد المدير الحالي من حسابه
  Future<void> registerSecondaryUser(UserModel user, String password) async {
    FirebaseApp? secondaryApp;
    try {
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (_) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform, // ← تم الإصلاح هنا
        );
      }

      // ... باقي الكود الخاص بالدالة كما هو بدون تغيير

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: '${user.nationalID}@tahweela.com',
        password: password,
      );

      final updatedUser = UserModel(
        uid: userCredential.user!.uid,
        nationalID: user.nationalID,
        name: user.name,
        phone: user.phone,
        role: user.role,
        specialty: user.specialty,
        createdAt: user.createdAt,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(updatedUser.toMap());
      await secondaryAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
