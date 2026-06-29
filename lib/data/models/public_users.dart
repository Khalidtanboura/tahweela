import 'package:cloud_firestore/cloud_firestore.dart';

class PublicUserModel {
  final String documentId;
  final String publicUserId;
  final String fullName;
  final String gender;
  final String nationalId;
  final int age;
  final bool isLinked;
  final String? appUserUid;
  final DateTime? createdAt;

  const PublicUserModel({
    required this.documentId,
    required this.publicUserId,
    required this.fullName,
    required this.gender,
    required this.nationalId,
    required this.age,
    required this.isLinked,
    this.appUserUid,
    this.createdAt,
  });

  factory PublicUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return PublicUserModel.fromMap(doc.data() ?? {}, documentId: doc.id);
  }

  factory PublicUserModel.fromMap(
    Map<String, dynamic> map, {
    String documentId = '',
  }) {
    return PublicUserModel(
      documentId: documentId,
      publicUserId: map['public_user_id']?.toString() ?? documentId,
      fullName: map['full_name']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      nationalId: map['national_id']?.toString() ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      isLinked: map['is_linked'] == true,
      appUserUid: map['app_user_uid']?.toString(),
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'public_user_id': publicUserId,
      'full_name': fullName,
      'gender': gender,
      'national_id': nationalId,
      'age': age,
      'is_linked': isLinked,
      'app_user_uid': appUserUid,
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
    };
  }
}
