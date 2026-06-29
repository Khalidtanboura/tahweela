import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahweela/presentations/pages/auth/login.dart';
import 'package:tahweela/presentations/pages/auth/splash.dart';
import 'package:tahweela/presentations/pages/case_details/case_admin.dart';
import 'package:tahweela/presentations/pages/case_details/case_details_doctor.dart';
import 'package:tahweela/presentations/pages/case_details/case_patient.dart';
import 'package:tahweela/presentations/pages/case_details/case_review.dart';
import 'package:tahweela/presentations/pages/case_details/cases_list.dart';
import 'package:tahweela/presentations/pages/case_details/review.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_doctor_patient.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_patient_case.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_state.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/home/admin.dart';
import 'package:tahweela/presentations/pages/home/doctor.dart';
import 'package:tahweela/presentations/pages/home/patient.dart';
import 'package:tahweela/presentations/pages/notification.dart';
import 'package:tahweela/presentations/pages/profile.dart';
import 'package:tahweela/presentations/pages/referral/new_referral.dart';
import 'package:tahweela/presentations/pages/referral/secound_referral.dart';
import 'package:tahweela/presentations/pages/usermanagment.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahweela app',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const AuthGate(),
      locale: const Locale('ar', 'SA'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      routes: {
        '/home': (context) => const AuthGate(),
        'home': (context) => const AuthGate(),
        '/login': (context) => const Login(),
        'splash': (context) => const Splash(),
        'login': (context) => const Login(),
        '/patient': (context) => const Patient(),
        'patient': (context) => const Patient(),
        '/doctor': (context) => const Doctor(),
        'doctor': (context) => const Doctor(),
        '/admin': (context) => const Admin(),
        'admin': (context) => const Admin(),
        'usermanagment': (context) => UserManagment(),
        'casesList': (context) => CasesList(),
        'newReferral': (context) => NewReferral(),
        'secondReferral': (context) => SecondReferral(),
        'complaintsView': (context) => ComplaintsView(),
        'complaintState': (context) =>
            const ComplaintsState(complaintId: '', complaintData: {}),
        'complaints': (context) => Complaints(),
        'casePatient': (context) => CasePatient(),
        'caseAdmin': (context) => CaseAdmin(),
        'caseReview': (context) => CaseReview(),
        'caseDetailsDoctor': (context) => CaseDetailsDoctor(),
        'review': (context) => Review(),
        'myNotification': (context) => NotificationPage(),
        'profile': (context) => Profile(),
        'complaintsDoctorCase': (context) => ComplaintsDoctorCase(),
        'complaintsPatientCase': (context) => ComplaintsPatientCase(),
      },
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(userDataProvider);

    return authState.when(
      data: (userData) {
        if (userData == null) {
          return const Login();
        }

        switch (userData.role.trim().toLowerCase()) {
          case 'admin':
            return const Admin();
          case 'doctor':
            return const Doctor();
          case 'patient':
            return const Patient();
          default:
            return const Login();
        }
      },
      loading: () => const Splash(),
      error: (error, stackTrace) => const Login(),
    );
  }
}
