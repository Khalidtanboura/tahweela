import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tahweela/presentations/pages/case_details/case_admin.dart';
import 'package:tahweela/presentations/pages/case_details/case_details_doctor.dart';
import 'package:tahweela/presentations/pages/case_details/case_patient.dart';
import 'package:tahweela/presentations/pages/case_details/case_review.dart';
import 'package:tahweela/presentations/pages/case_details/review.dart';
import 'package:tahweela/presentations/pages/case_details/cases_list.dart';
import 'package:tahweela/presentations/pages/complaints/complaints.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_doctor_patient.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_patient_case.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_view.dart';
import 'package:tahweela/presentations/pages/complaints/complaints_state.dart';
import 'package:tahweela/presentations/pages/home/admin.dart';
import 'package:tahweela/presentations/pages/home/doctor.dart';
import 'package:tahweela/presentations/pages/home/patient.dart';
import 'package:tahweela/presentations/pages/auth/login.dart';
import 'package:tahweela/presentations/pages/notification.dart';
import 'package:tahweela/presentations/pages/profile.dart';
import 'package:tahweela/presentations/pages/referral/new_referral.dart';
import 'package:tahweela/presentations/pages/referral/secound_referral.dart';
import 'package:tahweela/presentations/pages/auth/splash.dart';
import 'package:tahweela/presentations/pages/usermanagment.dart';
import 'package:tahweela/providers/auth_provider.dart';
import 'core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(userRoleProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahweela app',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: authState.when(
        data: (role) {
          if (role == 'admin') {
            return const Admin();
          } else if (role == 'doctor') {
            return const Doctor();
          } else if (role == 'patient') {
            return const Patient();
          } else {
            // إذا كان null (غير مسجل دخول)
            return const Login();
          }
        },
        // ستظهر هذه الشاشة لمدة 3 ثوانٍ في كل مرة يفتح فيها التطبيق
        loading: () => const Splash(),
        error: (e, trace) => const Login(),
      ),
      // initialRoute: 'splash',
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
