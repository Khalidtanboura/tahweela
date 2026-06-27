import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/usermanagment.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/complanits_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../notification.dart';
import '../profile.dart';
import '../case_details/cases_list.dart';

class Admin extends ConsumerWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref
        .watch(userDataProvider)
        .when(
          data: (user) =>
              titleCard(title: 'مرحباً، ${user?.name ?? 'مدير النظام'}'),
          loading: () => titleCard(title: 'مرحباً، مدير النظام'),
          error: (_, __) => titleCard(title: 'مرحباً، مدير النظام'),
        );

    // مراقبة عدادات الشكاوى الجديدة هنا 👇
    final totalComplaintsAsync = ref.watch(totalComplaintsCountProvider);
    final pendingComplaintsAsync = ref.watch(pendingComplaintsCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              // Header: Notifications + Profile
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
                      // Notifications
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

                      // Profile
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
                            // يمكنك ربطها بمزود الحالات لاحقاً بنفس الطريقة
                            color: Colors.blueAccent,
                            lableText: 'إجمالي الحالات',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: '3',
                            color: Colors.green,
                            lableText: 'بانتظار M المراجعة',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // التحديث الذكي لكروت الشكاوى هنا 👇
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SecoundCard(
                            value: totalComplaintsAsync.when(
                              data: (count) => count.toString(),
                              loading: () => '...',
                              error: (_, __) => '0',
                            ),
                            color: Colors.red,
                            lableText: 'شكاوى',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: pendingComplaintsAsync.when(
                              data: (count) => count.toString(),
                              loading: () => '...',
                              error: (_, __) => '0',
                            ),
                            color: const Color(0xffF59E0B),
                            lableText: 'قيد الانتظار',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),
                    cardButton(
                      title: 'إدارة المستخدمين',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserManagment(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    cardButton(
                      title: 'جميع الحالات',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CasesList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    cardButton(
                      title: 'الشكاوي',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComplaintsView(),
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
