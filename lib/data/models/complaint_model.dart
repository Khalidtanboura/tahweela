import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String text;
  final String status;
  final String replyText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.text,
    this.status = 'pending',
    this.replyText = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ComplaintModel.fromMap(data, id: doc.id);
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return ComplaintModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      userRole: data['userRole']?.toString() ?? 'patient',
      text: (data['text'] ?? data['complaintText'] ?? '').toString(),
      status: data['status']?.toString() ?? 'pending',
      replyText: data['replyText']?.toString() ?? '',
      createdAt: _dateFromFirestore(data['createdAt']),
      updatedAt: _dateFromFirestore(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool useServerTimestamp = true}) {
    final createdAtValue = createdAt == null
        ? FieldValue.serverTimestamp()
        : Timestamp.fromDate(createdAt!);

    return {
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'text': text,
      'complaintText': text,
      'status': status,
      'replyText': replyText,
      'createdAt': useServerTimestamp ? createdAtValue : createdAt,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _dateFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
