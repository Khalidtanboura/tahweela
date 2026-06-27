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
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetRole,
    this.targetUid,
    required this.type,
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
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  // ميزة ذكية: تحديد الأيقونة واللون بناءً على نوع الإشعار لتطابق هوية Figma
  IconData get icon {
    switch (type) {
      case 'new_referral':
        return Icons.assignment_turned_in_outlined;
      case 'complaint_update':
        return Icons.warning_amber_rounded;
      case 'system_alert':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color get iconColor {
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
