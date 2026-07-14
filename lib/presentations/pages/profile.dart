import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'package:tahweela/providers/login_provider.dart';

import '../widgets/card.dart';

class Profile extends ConsumerWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مراقبة مزود البيانات الشامل
    final authState = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: authState.when(
          // حالة النجاح في جلب البيانات من الـ Firestore
          data: (userData) {
            // ✅ 1. حماية الشاشة: إذا سجل المستخدم خروجاً وأصبحت البيانات null، نخرج بسلام دون انهيار
            if (userData == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF27AE60)),
              );
            }

            final String name = userData.name;
            final String nationalId = userData.nationalID;
            final String phone = userData.phone;
            final String dbRole = userData.role;

            // 3. تحويل نوع الحساب من الإنجليزية للعربية للعرض
            String roleText = 'مريض';
            if (dbRole == 'admin') {
              roleText = 'مدير النظام';
            } else if (dbRole == 'doctor') {
              roleText = 'طبيب';
            }

            // 3. أخذ أول حرف من الاسم بأمان ليكون الـ Avatar
            final String avatarChar = name.trim().isNotEmpty
                ? name.trim()[0]
                : 'U';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  // Header
                  secoundAppbarCard(
                    icon1: Icons.reply,
                    title: 'الملف الشخصي',
                    context: context,
                  ),

                  const SizedBox(height: 35),

                  // Profile Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1F9E9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        avatarChar,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27AE60),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    roleText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Profile Info Fields
                  Column(
                    children: [
                      _buildProfileInfoField(
                        label: 'رقم الهوية',
                        value: nationalId,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileInfoField(label: 'رقم الجوال', value: phone),
                      const SizedBox(height: 16),
                      _buildProfileInfoField(
                        label: 'نوع الحساب',
                        value: roleText,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Logout Button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 58),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        // 1. نطلب من الفايربيز تسجيل الخروج أولاً وننتظر النتيجة
                        await ref.read(firebaseAuthProvider).signOut();
                        ref.read(loginControllerProvider.notifier).reset();

                        // 2. إذا نجحت العملية (ولم يحدث استثناء)، ننتقل فوراً لصفحة الـ login ونفرغ الذاكرة
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            'login', // ✅ استخدام 'login' بدلاً من '/' لتفادي الانهيار
                            (Route<dynamic> route) => false,
                          );
                        }
                      } catch (e) {
                        // 3. إذا فشل تسجيل الخروج لأي سبب (مثل انقطاع الإنترنت)، نلغي الانتقال وننبه المستخدم
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'فشل تسجيل الخروج، يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
                                textAlign: TextAlign.right,
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },

          // شاشة الانتظار المريحة للعين أثناء تحميل البيانات
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF27AE60)),
          ),

          // في حال حدوث خطأ غير متوقع في الاتصال بالإنترنت
          error: (error, stack) => const Center(
            child: Text(
              'حدث خطأ أثناء تحميل بيانات الملف الشخصي',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoField({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
