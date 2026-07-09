import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/case_details/cases_list.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/user_complaints_page.dart';
import 'package:tahweela/presentations/pages/profile.dart';
import 'package:tahweela/presentations/pages/referral/new_referral.dart';
import 'package:tahweela/presentations/widgets/buttons.dart';
import 'package:tahweela/presentations/widgets/card.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';
import 'package:tahweela/providers/providers.dart';

class Doctor extends ConsumerStatefulWidget {
  const Doctor({super.key});

  @override
  ConsumerState<Doctor> createState() => _DoctorState();
}

class _DoctorState extends ConsumerState<Doctor> {
  String _totalCases = '0';
  String _waitingReview = '0';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCounts);
  }

  Future<void> _loadCounts() async {
    final results = await Future.wait<int>([
      ref.read(doctorSpecialtyReferralsCountOnceProvider.future),
      ref.read(doctorPendingMedicalReviewCountOnceProvider.future),
    ]);
    if (!mounted) return;
    setState(() {
      _totalCases = results[0].toString();
      _waitingReview = results[1].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref
        .watch(userDataProvider)
        .when(
          data: (user) => titleCard(title: 'مرحبا، ${user?.name ?? 'دكتور'}'),
          loading: () => titleCard(title: 'مرحبا دكتور'),
          error: (error, stackTrace) => titleCard(title: 'مرحبا دكتور'),
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                const _DoctorHeader(),
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      userName,
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: SecoundCard(
                              value: _totalCases,
                              color: Colors.blueAccent,
                              lableText: 'إجمالي الحالات',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SecoundCard(
                              value: _waitingReview,
                              color: const Color(0xffF59E0B),
                              lableText: 'بانتظار المراجعة',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      cardButton(
                        title: 'مراجعة الحالات',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CasesList(
                                mode: CasesListMode.medicalReview,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      cardButton(
                        title: 'إنشاء حالة جديدة',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewReferral(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      cardButton(
                        title: 'تقديم شكوى',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Complaints(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      cardButton(
                        title: 'الشكاوى',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserComplaintsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorHeader extends ConsumerWidget {
  const _DoctorHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsOnceProvider);

    return Container(
      height: 86,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B9E4F),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            notificationsAsync.when(
              data: (list) {
                final unreadCount = list.where((item) => !item.isRead).length;
                return buildNotificationBell(context, unreadCount);
              },
              loading: () => const SizedBox(),
              error: (error, stackTrace) => const SizedBox(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
