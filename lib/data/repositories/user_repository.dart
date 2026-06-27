import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // تأكد من المسار

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب بيانات مستخدم واحد (للملف الشخصي)
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // تحديث بيانات الملف الشخصي
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // جلب قائمة بالمرضى (لكي يختار الطبيب من بينهم لعمل تحويل)
  Future<List<UserModel>> getAllPatients() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }
}
