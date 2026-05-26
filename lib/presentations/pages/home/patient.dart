
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/buttons.dart';
import '../../widgets/card.dart';
import '../notification.dart';
import '../profile.dart';
import '../case_details/cases_list.dart';
class Patient extends ConsumerWidget {
  const Patient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xffF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
