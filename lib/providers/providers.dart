import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import 'package:tahweela/data/repositories/user_repository.dart';
import 'package:tahweela/providers/notifications_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  final notificationsRepo = ref.watch(notificationsRepositoryProvider);
  return ReferralsRepository(notificationsRepo: notificationsRepo);
});

final adminReferralsProvider = StreamProvider.autoDispose<List<ReferralModel>>((
  ref,
) {
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin');
});

final totalReferralsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin')
      .map((items) => items.length);
});

final pendingReferralsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin')
      .map((items) => items.where((item) => item.status == 'pending').length);
});

final medicalReviewReferralsProvider =
    StreamProvider.autoDispose<List<ReferralModel>>((ref) {
      return ref
          .watch(referralsRepositoryProvider)
          .streamMedicalReviewReferrals();
    });
