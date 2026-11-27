import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/login_screen.dart';

void main() {
  Widget createLoginApp({
    void Function(String username)? onLoginSuccess,
    VoidCallback? onNavigateToRegister,
  }) {
    return MaterialApp(
      home: LoginScreen(
        onLoginSuccess: onLoginSuccess,
        onNavigateToRegister: onNavigateToRegister,
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('1. Renders all header, hero, and branding elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginApp());

      // Brand logo
      expect(find.text('solvzie'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('fess'), findsOneWidget);

      // Hero Title & Subtitle
      expect(find.text('HALO!'), findsOneWidget);
      expect(find.text('WELCOME BACK'), findsOneWidget);
      expect(find.text('Ada pesan rahasia menunggumu.'), findsOneWidget);

      // Card Fields & Button
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Tetap masuk'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Belum punya akun? '), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);

      // Footer note
      expect(find.text('100% anonim, 100% kamu.'), findsOneWidget);
    });

    testWidgets('2. Password visibility toggle works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginApp());

      // Find password TextField
      final passwordFinder = find.widgetWithText(TextField, '');
      expect(passwordFinder, findsNWidgets(2)); // username and password

      // Initially password is obscured
      TextField passwordField = tester.widget<TextField>(passwordFinder.last);
      expect(passwordField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap toggle eye icon
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      // Password should now be visible
      passwordField = tester.widget<TextField>(passwordFinder.last);
      expect(passwordField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap toggle again
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      passwordField = tester.widget<TextField>(passwordFinder.last);
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('3. Checkbox "Tetap masuk" toggles on and off on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginApp());

      // Initially checked (rememberMe = true)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Tap "Tetap masuk"
      await tester.tap(find.text('Tetap masuk'));
      await tester.pump();

      // Now unchecked
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap again to re-check
      await tester.tap(find.text('Tetap masuk'));
      await tester.pump();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('4. Form validation displays required errors on empty submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginApp());

      // Errors not visible before submit
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);
      expect(find.text('Password minimal 6 karakter.'), findsNothing);

      // Tap "Masuk"
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      // Errors should now be displayed
      expect(find.text('Minimal 3 karakter, ya.'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
    });

    testWidgets('5. Form validation passes when valid inputs are provided',
        (WidgetTester tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(createLoginApp(
        onLoginSuccess: (_) => loginCalled = true,
      ));

      // Enter valid username and password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'solvzie_user');
      await tester.enterText(textFields.last, 'secret123');
      await tester.pump();

      // Tap "Masuk"
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      // No validation errors should be displayed
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);
      expect(find.text('Password minimal 6 karakter.'), findsNothing);
      expect(loginCalled, isTrue);
    });

    testWidgets('6. Tap "Daftar" triggers register callback',
        (WidgetTester tester) async {
      bool registerCalled = false;

      await tester.pumpWidget(createLoginApp(
        onNavigateToRegister: () => registerCalled = true,
      ));

      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(registerCalled, isTrue);
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

        await tester.pumpWidget(createLoginApp());
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
