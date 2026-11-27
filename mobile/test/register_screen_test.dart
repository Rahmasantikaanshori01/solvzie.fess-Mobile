import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/register_screen.dart';

void main() {
  Widget createRegisterApp({
    VoidCallback? onRegisterSuccess,
    VoidCallback? onNavigateToLogin,
  }) {
    return MaterialApp(
      home: RegisterScreen(
        onRegisterSuccess: onRegisterSuccess,
        onNavigateToLogin: onNavigateToLogin,
      ),
    );
  }

  group('RegisterScreen Widget Tests', () {
    testWidgets('1. Renders all header, hero, and branding elements for Register',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterApp());

      // Brand logo
      expect(find.text('solvzie'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('fess'), findsOneWidget);

      // Hero Title & Subtitle for Register
      expect(find.text('DAFTAR'), findsOneWidget);
      expect(find.text('GABUNG, YUK!'), findsOneWidget);
      expect(find.text('Bikin ruang rahasiamu sendiri.'), findsOneWidget);

      // Card Fields & Button
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi password'), findsOneWidget);
      expect(find.text('Buat akun'), findsOneWidget);
      expect(find.text('Sudah punya akun? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Must NOT have "Tetap masuk" (only on Login)
      expect(find.text('Tetap masuk'), findsNothing);

      // Footer note
      expect(find.text('100% anonim, 100% kamu.'), findsOneWidget);
    });

    testWidgets('2. Password visibility toggle works for both password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterApp());

      // 4 text fields: Username, Email, Password, Konfirmasi password
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      // Both password fields initially obscured
      expect(tester.widget<TextField>(textFields.at(2)).obscureText, isTrue);
      expect(tester.widget<TextField>(textFields.at(3)).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));

      // Tap first eye icon (Password toggle)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      // Password field should be revealed, Confirm still obscured
      expect(tester.widget<TextField>(textFields.at(2)).obscureText, isFalse);
      expect(tester.widget<TextField>(textFields.at(3)).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap second eye icon (Confirm toggle)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      // Both fields now revealed
      expect(tester.widget<TextField>(textFields.at(2)).obscureText, isFalse);
      expect(tester.widget<TextField>(textFields.at(3)).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));
    });

    testWidgets('3. Form validation displays errors on empty submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterApp());

      // Errors not visible before submit
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);
      expect(find.text('Masukkan email yang valid.'), findsNothing);
      expect(find.text('Password minimal 6 karakter.'), findsNothing);

      // Tap "Buat akun"
      await tester.tap(find.text('Buat akun'));
      await tester.pump();

      // Errors should now be displayed
      expect(find.text('Minimal 3 karakter, ya.'), findsOneWidget);
      expect(find.text('Masukkan email yang valid.'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
    });

    testWidgets('4. Form validation displays error when passwords do not match',
        (WidgetTester tester) async {
      await tester.pumpWidget(createRegisterApp());

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'naya_fess');
      await tester.enterText(textFields.at(1), 'naya@email.com');
      await tester.enterText(textFields.at(2), 'secret123');
      await tester.enterText(textFields.at(3), 'different456');
      await tester.pump();

      // Tap "Buat akun"
      await tester.tap(find.text('Buat akun'));
      await tester.pump();

      expect(find.text('Password belum sama.'), findsOneWidget);
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);
      expect(find.text('Masukkan email yang valid.'), findsNothing);
      expect(find.text('Password minimal 6 karakter.'), findsNothing);
    });

    testWidgets('5. Form validation passes with all valid fields',
        (WidgetTester tester) async {
      bool registerSuccessCalled = false;

      await tester.pumpWidget(createRegisterApp(
        onRegisterSuccess: () => registerSuccessCalled = true,
      ));

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'naya_fess');
      await tester.enterText(textFields.at(1), 'naya@email.com');
      await tester.enterText(textFields.at(2), 'secret123');
      await tester.enterText(textFields.at(3), 'secret123');
      await tester.pump();

      // Tap "Buat akun"
      await tester.tap(find.text('Buat akun'));
      await tester.pump();

      // No error messages
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);
      expect(find.text('Masukkan email yang valid.'), findsNothing);
      expect(find.text('Password minimal 6 karakter.'), findsNothing);
      expect(find.text('Password belum sama.'), findsNothing);
      expect(registerSuccessCalled, isTrue);
    });

    testWidgets('6. Tap "Login" triggers onNavigateToLogin callback',
        (WidgetTester tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(createRegisterApp(
        onNavigateToLogin: () => loginCalled = true,
      ));

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(loginCalled, isTrue);
    });

    testWidgets('7. Layout does not overflow on standard screen sizes',
        (WidgetTester tester) async {
      final screenSizes = [
        const Size(360, 640), // small phone
        const Size(390, 844), // iPhone 14
        const Size(430, 932), // iPhone 14 Pro Max
        const Size(800, 1280), // tablet portrait
      ];

      for (final size in screenSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createRegisterApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'Overflow on size $size');
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
