import 'package:flutter_riverpod/flutter_riverpod.dart';
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
