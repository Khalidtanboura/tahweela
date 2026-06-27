import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tahweela/presentations/pages/auth/login.dart';

void main() {
  testWidgets('Login screen renders the sign-in form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: Login())),
    );

    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
