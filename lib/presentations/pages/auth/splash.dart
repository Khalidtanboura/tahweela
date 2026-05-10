import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    Timer(
      Duration(seconds: 3),
      () => Navigator.pushReplacementNamed(context, 'login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff16A34A),
      body: Center(
        child: Column(
          children: [
            Container(
              // color: Color(0xffDCFCE7),
              margin: EdgeInsets.only(top: 178),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffDCFCE7),
              ),
              child: Icon(
                Icons.medical_services_sharp,
                size: 60,
                color: Color(0xff16A34A),
              ),
            ),
            SizedBox(height: 26),
            Text('تحويلة', style: TextStyle(fontSize: 30, color: Colors.white)),
            SizedBox(height: 17),
            Text(
              'نظام التحويل الطبي الذكي',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            // SizedBox(height: 30),
            // CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
