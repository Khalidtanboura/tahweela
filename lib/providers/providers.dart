import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/data/models/referral_model.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import 'package:tahweela/data/repositories/user_repository.dart';
import 'package:tahweela/providers/auth_provider.dart';
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

final totalReferralsCountOnceProvider = FutureProvider.autoDispose<int>((ref) {
  return ref
      .watch(referralsRepositoryProvider)
      .fetchReferralModels(role: 'admin')
      .then((items) => items.length);
});

final pendingReferralsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin')
      .map((items) => items.where((item) => item.status == 'pending').length);
});

final pendingMedicalReviewCountProvider = StreamProvider.autoDispose<int>((
  ref,
) {
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin')
      .map((items) => items.where(_isWaitingForMedicalReview).length);
});

final pendingMedicalReviewCountOnceProvider = FutureProvider.autoDispose<int>((
  ref,
) {
  return ref
      .watch(referralsRepositoryProvider)
      .fetchReferralModels(role: 'admin')
      .then((items) => items.where(_isWaitingForMedicalReview).length);
});

final patientReferralsProvider =
    StreamProvider.autoDispose<List<ReferralModel>>((ref) {
      final user = ref.watch(userDataProvider).value;
      if (user == null) return const Stream.empty();
      return ref
          .watch(referralsRepositoryProvider)
          .streamReferralModels(role: 'patient', uid: user.uid);
    });

final medicalReviewReferralsProvider =
    StreamProvider.autoDispose<List<ReferralModel>>((ref) {
      final user = ref.watch(userDataProvider).value;
      return ref
          .watch(referralsRepositoryProvider)
          .streamMedicalReviewReferrals(
            specialty: user?.specialty,
            reviewerId: user?.uid,
          );
    });

final doctorSpecialtyReferralsCountProvider = StreamProvider.autoDispose<int>((
  ref,
) {
  final user = ref.watch(userDataProvider).value;
  final specialty = ReferralsRepository.normalizeSpecialty(
    user?.specialty ?? '',
  );
  if (specialty.isEmpty) return Stream.value(0);

  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'admin')
      .map(
        (items) => items.where((item) {
          final assigned = ReferralsRepository.normalizeSpecialty(
            item.assignedSpecialty,
          );
          final inferred = ReferralsRepository.specialtyForDiseaseType(
            item.diseaseType,
          );
          return assigned == specialty || inferred == specialty;
        }).length,
      );
});

final doctorSpecialtyReferralsCountOnceProvider =
    FutureProvider.autoDispose<int>((ref) {
      final user = ref.watch(userDataProvider).value;
      final specialty = ReferralsRepository.normalizeSpecialty(
        user?.specialty ?? '',
      );
      if (specialty.isEmpty) return Future.value(0);

      return ref
          .watch(referralsRepositoryProvider)
          .fetchReferralModels(role: 'admin')
          .then(
            (items) => items.where((item) {
              final assigned = ReferralsRepository.normalizeSpecialty(
                item.assignedSpecialty,
              );
              final inferred = ReferralsRepository.specialtyForDiseaseType(
                item.diseaseType,
              );
              return assigned == specialty || inferred == specialty;
            }).length,
          );
    });

final doctorPendingMedicalReviewCountOnceProvider =
    FutureProvider.autoDispose<int>((ref) {
      final user = ref.watch(userDataProvider).value;
      return ref
          .watch(referralsRepositoryProvider)
          .fetchMedicalReviewReferrals(
            specialty: user?.specialty,
            reviewerId: user?.uid,
          )
          .then((items) => items.length);
    });

final patientAcceptedReferralsCountProvider = StreamProvider.autoDispose<int>((
  ref,
) {
  final user = ref.watch(userDataProvider).value;
  if (user == null) return Stream.value(0);
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'patient', uid: user.uid)
      .map((items) => items.where((item) => item.status == 'accepted').length);
});

final patientAcceptedReferralsCountOnceProvider =
    FutureProvider.autoDispose<int>((ref) {
      final user = ref.watch(userDataProvider).value;
      if (user == null) return Future.value(0);
      return ref
          .watch(referralsRepositoryProvider)
          .fetchReferralModels(role: 'patient', uid: user.uid)
          .then(
            (items) => items.where((item) => item.status == 'accepted').length,
          );
    });

final patientRejectedReferralsCountProvider = StreamProvider.autoDispose<int>((
  ref,
) {
  final user = ref.watch(userDataProvider).value;
  if (user == null) return Stream.value(0);
  return ref
      .watch(referralsRepositoryProvider)
      .streamReferralModels(role: 'patient', uid: user.uid)
      .map((items) => items.where((item) => item.status == 'rejected').length);
});

final patientRejectedReferralsCountOnceProvider =
    FutureProvider.autoDispose<int>((ref) {
      final user = ref.watch(userDataProvider).value;
      if (user == null) return Future.value(0);
      return ref
          .watch(referralsRepositoryProvider)
          .fetchReferralModels(role: 'patient', uid: user.uid)
          .then(
            (items) => items.where((item) => item.status == 'rejected').length,
          );
    });

bool _isWaitingForMedicalReview(ReferralModel referral) {
  switch (referral.status.trim().toLowerCase()) {
    case 'accepted':
    case 'rejected':
    case 'returned':
    case 'closed':
      return false;
    default:
      return true;
  }
}
