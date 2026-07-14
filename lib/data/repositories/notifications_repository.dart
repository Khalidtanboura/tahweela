import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> streamNotifications({
    required String role,
    required String uid,
    String? specialty,
  }) {
    return _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .where((notification) {
                final uidMatches =
                    notification.targetUid == null ||
                    notification.targetUid == uid;
                final targetSpecialty =
                    notification.targetSpecialty?.trim() ?? '';
                final specialtyMatches =
                    targetSpecialty.isEmpty ||
                    targetSpecialty == specialty?.trim();

                return uidMatches && specialtyMatches;
              })
              .toList();
          _sortNewestFirst(notifications);

          return notifications;
        });
  }

  Future<List<NotificationModel>> fetchNotifications({
    required String role,
    required String uid,
    String? specialty,
  }) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: role)
        .get();

    final notifications = snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .where((notification) {
          final uidMatches =
              notification.targetUid == null || notification.targetUid == uid;
          final targetSpecialty = notification.targetSpecialty?.trim() ?? '';
          final specialtyMatches =
              targetSpecialty.isEmpty || targetSpecialty == specialty?.trim();

          return uidMatches && specialtyMatches;
        })
        .toList();
    _sortNewestFirst(notifications);
    return notifications;
  }

  static void _sortNewestFirst(List<NotificationModel> notifications) {
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> sendNotificationToAdmin({
    required String title,
    required String body,
    required String type,
    String? relatedId,
    String? routeName,
  }) async {
    await _createNotification(
      title: title,
      body: body,
      targetRole: 'admin',
      type: type,
      relatedId: relatedId,
      routeName: routeName,
    );
  }

  Future<void> sendNotificationToDoctor({
    required String doctorUid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
    String? routeName,
  }) async {
    await _createNotification(
      title: title,
      body: body,
      targetRole: 'doctor',
      targetUid: doctorUid,
      type: type,
      relatedId: relatedId,
      routeName: routeName,
    );
  }

  Future<void> sendNotificationToAllDoctors({
    required String title,
    required String body,
    required String type,
    String? targetSpecialty,
    String? relatedId,
    String? routeName,
  }) async {
    await _createNotification(
      title: title,
      body: body,
      targetRole: 'doctor',
      targetSpecialty: targetSpecialty,
      type: type,
      relatedId: relatedId,
      routeName: routeName,
    );
  }

  Future<void> sendNotificationToPatient({
    required String patientUid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
    String? routeName,
  }) async {
    await _createNotification(
      title: title,
      body: body,
      targetRole: 'patient',
      targetUid: patientUid,
      type: type,
      relatedId: relatedId,
      routeName: routeName,
    );
  }

  Future<void> _createNotification({
    required String title,
    required String body,
    required String targetRole,
    required String type,
    String? targetUid,
    String? targetSpecialty,
    String? relatedId,
    String? routeName,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'targetRole': targetRole,
      'targetUid': targetUid,
      'targetSpecialty': targetSpecialty,
      'relatedId': relatedId,
      'routeName': routeName,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
