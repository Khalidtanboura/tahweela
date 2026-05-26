import 'package:flutter/material.dart';

import '../case_details/review.dart';
import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../notification.dart';
import '../profile.dart';

class Doctor extends StatelessWidget {
  const Doctor({super.key});

  @override
  Widget build(BuildContext context) {
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
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyNotification(),
                            ),
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
                    const SizedBox(height: 20),

                   titleCard(title: 'تجربة الطبيب'),

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

                    cardButton(
                      title: 'مراجعة الحالات',
                      onTap: () {},
                    ),

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
                      title: 'الشكاوي ',
                      onTap: () {},
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