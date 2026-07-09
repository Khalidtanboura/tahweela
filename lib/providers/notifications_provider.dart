import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tahweela/data/models/notification_model.dart';
import 'package:tahweela/data/repositories/notifications_repository.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import 'auth_provider.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository();
});

// مزود ديناميكي يراقب حالة المستخدم الحالي ويجلب إشعاراته المخصصة فوراً
final userNotificationsProvider = StreamProvider<List<NotificationModel>>((
  ref,
) {
  final authState = ref.watch(userDataProvider);
  final repo = ref.watch(notificationsRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return repo.streamNotifications(
        role: user.role,
        uid: user.uid,
        specialty: ReferralsRepository.normalizeSpecialty(user.specialty ?? ''),
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final userNotificationsOnceProvider = FutureProvider<List<NotificationModel>>((
  ref,
) {
  final authState = ref.watch(userDataProvider);
  final repo = ref.watch(notificationsRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Future.value([]);
      return repo
          .streamNotifications(
            role: user.role,
            uid: user.uid,
            specialty: ReferralsRepository.normalizeSpecialty(
              user.specialty ?? '',
            ),
          )
          .first;
    },
    loading: () => Future.value([]),
    error: (_, __) => Future.value([]),
  );
});

final deviceMessagingProvider = Provider<void>((ref) {
  final user = ref.watch(userDataProvider).value;
  if (user == null) return;

  final messaging = FirebaseMessaging.instance;
  final firestore = FirebaseFirestore.instance;

  Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    await firestore.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  messaging.getToken().then(saveToken);
  final subscription = messaging.onTokenRefresh.listen(saveToken);
  ref.onDispose(subscription.cancel);
});
