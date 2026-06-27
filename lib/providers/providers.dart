import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import 'package:tahweela/data/repositories/user_repository.dart';
import 'package:tahweela/providers/notifications_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// 2. مزود التحويلات (يحتاج أن نحقن فيه الإشعارات)
final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  final notificationsRepo = ref.watch(notificationsRepositoryProvider);
  return ReferralsRepository(notificationsRepo: notificationsRepo);
});
