import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tahweela/data/models/public_users.dart';

class PublicUsersRepository {
  PublicUsersRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('public_users');

  Future<PublicUserModel?> findByNationalId(String nationalId) async {
    final snapshot = await _collection
        .where('national_id', isEqualTo: nationalId.trim())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PublicUserModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> linkToAppUser({
    required String documentId,
    required String appUserUid,
  }) async {
    await _collection.doc(documentId).update({
      'is_linked': true,
      'app_user_uid': appUserUid,
      'linked_at': FieldValue.serverTimestamp(),
    });
  }
}
