import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nationalID;
  final String name;
  final String phone;
  final String role;
  final String? specialty;
  final String? publicUserId;
  final String? gender;
  final int? age;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nationalID,
    required this.name,
    required this.phone,
    required this.role,
    this.specialty,
    this.publicUserId,
    this.gender,
    this.age,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: data['uid']?.toString() ?? doc.id,
      email: data['email']?.toString() ?? 'غير متوفر',
      nationalID:
          data['nationalID']?.toString() ??
          data['nationalId']?.toString() ??
          'غير متوفر',
      name: data['name']?.toString() ?? 'مستخدم غير معروف',
      phone: data['phone']?.toString() ?? 'غير متوفر',
      role: data['role']?.toString() ?? 'patient',
      specialty: data['specialty']?.toString(),
      publicUserId:
          data['publicUserId']?.toString() ??
          data['public_user_id']?.toString(),
      gender: data['gender']?.toString(),
      age: (data['age'] as num?)?.toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nationalID': nationalID,
      'name': name,
      'phone': phone,
      'role': role,
      if (specialty != null) 'specialty': specialty,
      if (publicUserId != null) 'publicUserId': publicUserId,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  String get roleInArabic {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'doctor':
        return 'طبيب';
      case 'patient':
      default:
        return 'مريض';
    }
  }
}
