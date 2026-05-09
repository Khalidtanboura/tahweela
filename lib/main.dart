import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tahweela/presentations/pages/case_details/case_admin.dart';
import 'package:tahweela/presentations/pages/case_details/case_details_doctor.dart';
import 'package:tahweela/presentations/pages/case_details/case_patient.dart';
import 'package:tahweela/presentations/pages/case_details/case_review.dart';
import 'package:tahweela/presentations/pages/case_details/review.dart';
import 'package:tahweela/presentations/pages/cases_list.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_doctor_patient.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_patient_case.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_state.dart';
import 'package:tahweela/presentations/pages/home/admin.dart';
import 'package:tahweela/presentations/pages/home/doctor.dart';
import 'package:tahweela/presentations/pages/home/patient.dart';
import 'package:tahweela/presentations/pages/login.dart';
import 'package:tahweela/presentations/pages/notification.dart';
import 'package:tahweela/presentations/pages/profile.dart';
import 'package:tahweela/presentations/pages/referral/new_referral.dart';
import 'package:tahweela/presentations/pages/referral/secound_referral.dart';
import 'package:tahweela/presentations/pages/splash.dart';
import 'package:tahweela/presentations/pages/usermanagment.dart';
import 'core/theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // جعل الخلفية شفافة
      statusBarIconBrightness:
          Brightness.light, // جعل الأيقونات (ساعة، بطارية) باللون الأبيض
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahweela app',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: 'complaintsDoctorCase',
      locale: const Locale('ar', 'SA'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      routes: {
        'splash': (context) => const Splash(),
        'login': (context) => Login(),
        'patient': (context) => Patient(),
        'doctor': (context) => Doctor(),
        'admin': (context) => Admin(),
        'usermanagment': (context) => UserManagment(),
        'casesList': (context) => CasesList(),
        'newReferral': (context) => NewReferral(),
        'secondReferral': (context) => SecondReferral(),
        'complaintsView': (context) => ComplaintsView(),
        'complaintState': (context) => ComplaintsState(),
        'complaints': (context) => Complaints(),
        'casePatient': (context) => CasePatient(),
        'caseAdmin': (context) => CaseAdmin(),
        'caseReview': (context) => CaseReview(),
        'caseDetailsDoctor': (context) => CaseDetailsDoctor(),
        'review': (context) => Review(),
        'myNotification': (context) => MyNotification(),
        'profile': (context) => Profile(),
        'complaintsDoctorCase': (context) => ComplaintsDoctorCase(),
        'complaintsPatientCase': (context) => ComplaintsPatientCase(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text('tahweela', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
