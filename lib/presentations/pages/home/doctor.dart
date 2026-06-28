import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/user_complaints_page.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/complanits_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';
import '../case_details/review.dart';
import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../notification.dart';
import '../profile.dart';

class Doctor extends ConsumerWidget {
  const Doctor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref
        .watch(userDataProvider)
        .when(
          data: (user) => titleCard(title: 'مرحباً، ${user!.name ?? 'دكتور'}'),
          loading: () => titleCard(title: 'مرحبا ًدكتور'),
          error: (_, __) => titleCard(title: 'مرحبا ًدكتور'),
        );
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.notifications_none,
                      //     color: Colors.white,
                      //     size: 32,
                      //   ),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const NotificationPage(),
                      //       ),
                      //     );
                      //   },
                      // ),
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
                    const SizedBox(height: 20),
                    userName,

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SecoundCard(
                            value: '1',
                            color: Colors.blueAccent,
                            lableText: 'إجمالي الحالات',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: '3',
                            color: const Color(0xffF59E0B),
                            lableText: 'بانتظار المراجعة',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    cardButton(title: 'مراجعة الحالات', onTap: () {}),

                    const SizedBox(height: 12),

                    cardButton(
                      title: 'انشاء حالة جديدة',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Review(),
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
                      title: 'الشكاوي ',
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
    );
  }
}
