import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/card.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. قراءة بيانات المستخدم لمعرفة تخصيص العنوان
    final userState = ref.watch(userDataProvider);
    // 2. مراقبة تدفق الإشعارات المخصصة له
    final notificationsState = ref.watch(userNotificationsProvider);

    String pageTitle = 'الإشعارات';
    userState.whenData((user) {
      if (user != null) {
        if (user.role == 'admin') pageTitle = 'تنبيهات إدارة النظام';
        if (user.role == 'doctor') pageTitle = 'إشعارات العيادة الطبية';
        if (user.role == 'patient') pageTitle = 'إشعاراتي الصحية';
      }
    });

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
                title: pageTitle,
                context: context,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: notificationsState.when(
                  data: (notifications) {
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
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                  ),
                  error: (error, stack) => Center(
                    child: Text('حدث خطأ أثناء جلب التنبيهات: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
