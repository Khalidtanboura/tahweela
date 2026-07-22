import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String targetRole; // 'admin' أو 'doctor' أو 'patient'
  final String?
  targetUid; // محدد لـ UID معين (مثل مريض محدد) أو null لجميع أصحاب الدور (مثل كل المدراء)
  final String type; // 'new_referral', 'complaint_update', 'system_alert'
  final String? targetSpecialty;
  final String? relatedId;
  final String? routeName;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetRole,
    this.targetUid,
    required this.type,
    this.targetSpecialty,
    this.relatedId,
    this.routeName,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      targetRole: data['targetRole'] ?? 'patient',
      targetUid: data['targetUid'],
      type: data['type'] ?? 'system_alert',
      targetSpecialty: data['targetSpecialty']?.toString(),
      relatedId: data['relatedId']?.toString(),
      routeName: data['routeName']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'targetRole': targetRole,
      'targetUid': targetUid,
      'type': type,
      'targetSpecialty': targetSpecialty,
      'relatedId': relatedId,
      'routeName': routeName,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  // ميزة ذكية: تحديد الأيقونة واللون بناءً على نوع الإشعار لتطابق هوية Figma
  IconData get icon {
    switch (type) {
      case 'new_referral':
        return Icons.assignment_turned_in_outlined;
      case 'medical_review_completed':
        return Icons.fact_check_outlined;
      case 'complaint_update':
        return Icons.warning_amber_rounded;
      case 'system_alert':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color get iconColor {
    if (type == 'medical_review_completed') return const Color(0xFF2563EB);

    switch (type) {
      case 'new_referral':
        return const Color(0xFF16A34A); // أخضر تحويلات
      case 'complaint_update':
        return Colors.orange; // برتقالي شكاوى
      case 'system_alert':
      default:
        return Colors.blue; // أزرق للنظام
    }
  }
}
