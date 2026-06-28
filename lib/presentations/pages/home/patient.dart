import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_patient_case.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/complaints/user_complaints_page.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../notification.dart';
import '../profile.dart';
import '../case_details/cases_list.dart';

class Patient extends ConsumerWidget {
  const Patient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref
        .watch(userDataProvider)
        .when(
          data: (user) => titleCard(title: 'مرحباً، ${user!.name ?? 'المريض'}'),
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
                      Consumer(
                        builder: (context, ref, child) {
                          final notificationsAsync = ref.watch(
                            userNotificationsProvider,
                          );
                          return notificationsAsync.when(
                            data: (list) {
                              final unreadCount = list
                                  .where((n) => !n.isRead)
                                  .length;
                              return buildNotificationBell(
                                context,
                                unreadCount,
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          );
                        },
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
                            value: '1',
                            color: Colors.green,
                            lableText: 'المقبولة',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: '1',
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
                        Navigator.of(context).pushNamed('casesList');
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
