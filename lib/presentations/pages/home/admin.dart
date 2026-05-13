import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              appbarCard(
                onTap1: () async {
                  await FirebaseAuth.instance.signOut();
                },
                onTap2: () {},
                icon1: Icons.person_outline,
                icon2: Icons.notifications_none,
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    titleCard(title: 'مرحباً، مدير النظام'),
                    SizedBox(height: 28),
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
                            color: Colors.green,
                            lableText: 'بانتظار المراجعة',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SecoundCard(
                            value: '1',
                            color: Colors.red,
                            lableText: 'إجمالي الحالات',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SecoundCard(
                            value: '3',
                            color: Color(0xffF59E0B),
                            lableText: 'بانتظار المراجعة',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    cardButton(title: 'إدارة المستخدمين', onTap: () {}),
                    const SizedBox(height: 12),
                    cardButton(title: 'جميع الحالات', onTap: () {}),
                    const SizedBox(height: 12),

                    cardButton(title: 'الشكاوي ', onTap: () {}),
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
