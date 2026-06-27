import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nationalID;
  final String name;
  final String phone;
  final String role;
  final String? specialty;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.nationalID,
    required this.name,
    required this.phone,
    required this.role,
    this.specialty,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: data['uid'] ?? '',
      nationalID: data['nationalID'] ?? 'غير متوفر',
      name: data['name'] ?? 'مستخدم غير معروف',
      phone: data['phone'] ?? 'غير متوفر',
      role: data['role'] ?? 'patient',
      specialty: data['specialty'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nationalID': nationalID,
      'name': name,
      'phone': phone,
      'role': role,
      if (specialty != null) 'specialty': specialty,
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
