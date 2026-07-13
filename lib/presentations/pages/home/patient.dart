import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/user_complaints_page.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';
import 'package:tahweela/providers/providers.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../profile.dart';
import '../case_details/cases_list.dart';

class Patient extends ConsumerStatefulWidget {
  const Patient({super.key});

  @override
  ConsumerState<Patient> createState() => _PatientState();
}

class _PatientState extends ConsumerState<Patient> {
  String _acceptedReferrals = '0';
  String _rejectedReferrals = '0';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHomeData);
  }

  Future<void> _loadHomeData() async {
    final user = await ref.read(userDataProvider.future);
    if (user == null) return;

    final referrals = await ref
        .read(referralsRepositoryProvider)
        .fetchReferralModels(role: 'patient', uid: user.uid);
    final notifications = await ref
        .read(notificationsRepositoryProvider)
        .fetchNotifications(
          role: user.role,
          uid: user.uid,
          specialty: ReferralsRepository.normalizeSpecialty(
            user.specialty ?? '',
          ),
        );

    if (!mounted) return;
    setState(() {
      _acceptedReferrals = referrals
          .where((item) => item.status == 'accepted')
          .length
          .toString();
      _rejectedReferrals = referrals
          .where((item) => item.status == 'rejected')
          .length
          .toString();
      _unreadNotifications = notifications.where((item) => !item.isRead).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref
        .watch(userDataProvider)
        .when(
          data: (user) => titleCard(title: 'مرحباً، ${user?.name ?? 'المريض'}'),
          loading: () => titleCard(title: 'مرحباً، المريض'),
          error: (_, __) => titleCard(title: 'مرحباً، المريض'),
        );
    return Scaffold(
      backgroundColor: Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              Container(
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
                      buildNotificationBell(context, _unreadNotifications),
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
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    userName,
                    SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SecoundCard(
                            value: _acceptedReferrals,
                            color: Colors.green,
                            lableText: 'المقبولة',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: _rejectedReferrals,
                            color: Colors.blue,
                            lableText: 'المرفوضة',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    cardButton(
                      title: 'طلباتي',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CasesList(mode: CasesListMode.patient),
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
                          MaterialPageRoute(builder: (_) => const Complaints()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    cardButton(
                      title: 'شكاواي',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserComplaintsPage(),
                          ),
                          /* MaterialPageRoute(
                            builder: (_) => const ComplaintsView(),
                          ),*/
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
    );
  }
}
