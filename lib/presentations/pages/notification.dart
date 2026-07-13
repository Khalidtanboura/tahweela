import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tahweela/data/models/notification_model.dart';
import 'package:tahweela/data/models/user_model.dart';
import 'package:tahweela/data/repositories/referrals_repository.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/auth_provider.dart';
import 'case_details/cases_list.dart';
import '../widgets/card.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  late final Future<List<NotificationModel>> _notificationsFuture;
  UserModel? _user;
  String _pageTitle = 'الإشعارات';

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _loadNotifications();
  }

  Future<List<NotificationModel>> _loadNotifications() async {
    final user = await ref.read(userDataProvider.future);
    _user = user;

    if (mounted && user != null) {
      setState(() {
        _pageTitle = switch (user.role) {
          'admin' => 'تنبيهات إدارة النظام',
          'doctor' => 'إشعارات العيادة الطبية',
          'patient' => 'إشعاراتي الصحية',
          _ => 'الإشعارات',
        };
      });
    }

    if (user == null) return const <NotificationModel>[];
    return ref
        .read(notificationsRepositoryProvider)
        .fetchNotifications(
          role: user.role,
          uid: user.uid,
          specialty: ReferralsRepository.normalizeSpecialty(
            user.specialty ?? '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // استخدام الـ Appbar Card الموحد لديك في المشروع
              secoundAppbarCard(
                icon1: Icons.reply,
                title: _pageTitle,
                context: context,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<NotificationModel>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF16A34A),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء جلب التنبيهات: ${snapshot.error}',
                        ),
                      );
                    }

                    final notifications =
                        snapshot.data ?? const <NotificationModel>[];
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 70,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'صندوق الإشعارات فارغ حالياً',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final formattedTime = DateFormat(
                          'yyyy/MM/dd - hh:mm a',
                        ).format(item.createdAt);

                        return InkWell(
                          onTap: () {
                            // وضع الإشعار كـ مقروء عند ضغط المستخدم عليه
                            ref
                                .read(notificationsRepositoryProvider)
                                .markAsRead(item.id);
                            final routeName = item.routeName;
                            if (routeName != null && routeName.isNotEmpty) {
                              final user = _user;
                              if (routeName == 'casesList' &&
                                  user?.role == 'doctor') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CasesList(
                                      mode: CasesListMode.medicalReview,
                                    ),
                                  ),
                                );
                              } else if (routeName == 'casePatient' &&
                                  user?.role == 'patient') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CasesList(
                                      mode: CasesListMode.patient,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pushNamed(context, routeName);
                              }
                            }

                            // هندسة حركة التنقل مستقبلاً: يمكنك هنا فحص item.type
                            // وتوجيه المستخدم لشاشة الحالة أو الشكاوى المرتبطة بالإشعار
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? Colors.white
                                  : const Color(0xFFEFF6FF),
                              // خلفية زرقاء خفيفة جداً إن لم يقرأ بعد لمطابقة Figma
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: item.isRead
                                    ? Colors.grey.shade100
                                    : Colors.blue.shade100,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // دائرة الأيقونة الملونة ديناميكياً حسب نوع الإشعار
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: item.iconColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.iconColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // محتوى نص الإشعار المخصص
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: item.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              color: Colors.black87,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          if (!item.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.body,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          height: 1.4,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
