import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/providers/auth_provider.dart'; // تأكد من مسار الـ userDataProvider
import 'package:tahweela/providers/complanits_provider.dart'; // تأكد من مسار الـ myComplaintsProvider

import '../../widgets/card.dart';

class UserComplaintsPage extends ConsumerWidget {
  const UserComplaintsPage({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return const Color(0xFF27AE60);
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFFFFEAA7);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'مقبولة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return 'قيد المراجعة';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. معرفة دور المستخدم لتحديد التنسيق البصري (مريض أم طبيب)
    final userData = ref.watch(userDataProvider).value;
    final bool isDoctor = userData!.role == 'doctor';

    // 2. مراقبة تيار الشكاوى الخاص بالمستخدم الحالي
    final complaintsAsync = ref.watch(myComplaintsProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              secoundAppbarCard(
                icon1: Icons.reply,
                title: 'شكاواي',
                context: context,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: complaintsAsync.when(
                  // حالة النجاح وعرض البيانات
                  data: (complaintsList) {
                    if (complaintsList.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد شكاوى',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: complaintsList.length,
                      itemBuilder: (context, index) {
                        final data = complaintsList[index];
                        final status = data['status'] ?? 'pending';
                        final hasReply =
                            data['replyText'] != null &&
                            data['replyText'].toString().isNotEmpty;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              // 🌟 البطاقة الديناميكية (تتغير ألوانها بناءً على نوع الحساب)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDoctor
                                      ? Colors.white
                                      : const Color(0xFF2D7FF9),
                                  borderRadius: BorderRadius.circular(25),
                                  border: isDoctor
                                      ? Border.all(
                                          color: const Color(0xFFE3F2FD),
                                        )
                                      : null,
                                  boxShadow: isDoctor
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        data['userName'] ?? 'مجهول',
                                        style: TextStyle(
                                          color: isDoctor
                                              ? const Color(0xFF2D7FF9)
                                              : Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data['text'] ?? '',
                                      style: TextStyle(
                                        color: isDoctor
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status),
                                          borderRadius: BorderRadius.circular(
                                            isDoctor ? 20 : 15,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusLabel(status),
                                          style: TextStyle(
                                            color: _getStatusTextColor(status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // نص الرد الموحد (يظهر فقط لو في رد من الإدارة)
                              if (hasReply) ...[
                                const SizedBox(height: 15),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'نص الرد',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  alignment: Alignment.centerRight,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.blue.shade50,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    data['replyText'] ?? '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },

                  // حالة التحميل والانتظار
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                  ),

                  // حالة الخطأ في جلب تيار البيانات
                  error: (error, stack) => const Center(
                    child: Text(
                      'حدث خطأ في جلب الشكاوى',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
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
