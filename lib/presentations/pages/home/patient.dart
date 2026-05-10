import 'package:flutter/material.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';

class Patient extends StatelessWidget {
  const Patient({super.key});

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
                icon1: Icons.person_outline,
                icon2: Icons.notifications_none,
              ),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    titleCard(title: 'مرحباً، المريض'),
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
                    cardButton(title: 'تقديم شكوى', onTap: () {}),
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
