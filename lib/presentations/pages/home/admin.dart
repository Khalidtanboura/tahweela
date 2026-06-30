import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/case_details/cases_list.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/profile.dart';
import 'package:tahweela/presentations/pages/usermanagment.dart';
import 'package:tahweela/presentations/widgets/notificationBell.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/complanits_provider.dart';
import 'package:tahweela/providers/notifications_provider.dart';
import 'package:tahweela/providers/providers.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';

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

    final totalComplaintsAsync = ref.watch(totalComplaintsCountProvider);
    final pendingComplaintsAsync = ref.watch(pendingComplaintsCountProvider);
    final totalReferralsAsync = ref.watch(totalReferralsCountProvider);
    final pendingReferralsAsync = ref.watch(pendingReferralsCountProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                _Header(),
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
                              value: totalReferralsAsync.when(
                                data: (count) => count.toString(),
                                loading: () => '...',
                                error: (error, stackTrace) => '0',
                              ),
                              color: Colors.blueAccent,
                              lableText: 'إجمالي الحالات',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SecoundCard(
                              value: pendingReferralsAsync.when(
                                data: (count) => count.toString(),
                                loading: () => '...',
                                error: (error, stackTrace) => '0',
                              ),
                              color: Colors.green,
                              lableText: 'بانتظار M المراجعة',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SecoundCard(
                              value: totalComplaintsAsync.when(
                                data: (count) => count.toString(),
                                loading: () => '...',
                                error: (error, stackTrace) => '0',
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
                                error: (error, stackTrace) => '0',
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
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

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
