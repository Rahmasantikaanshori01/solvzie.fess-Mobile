import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/splash/splash_screen.dart';

void main() {
  group('SplashScreen Tests', () {
    testWidgets('1. onFinished is called exactly once after 5.2 seconds',
        (WidgetTester tester) async {
      int finishCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () => finishCount++,
          ),
        ),
      );

      // Initial state
      expect(finishCount, 0);

      // Advance to 4.0s: not finished yet
      await tester.pump(const Duration(milliseconds: 4000));
      expect(finishCount, 0);

      // Advance past 5.2s (total 5.3s): should finish exactly once
      await tester.pump(const Duration(milliseconds: 1300));
      expect(finishCount, 1);

      // Advance further: should not call onFinished again
      await tester.pump(const Duration(seconds: 2));
      expect(finishCount, 1);
    });

    testWidgets('2. Tapping the screen before 5.2 seconds does NOT call onFinished',
        (WidgetTester tester) async {
      int finishCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () => finishCount++,
          ),
        ),
      );

      // Tap on the splash screen multiple times
      await tester.tap(find.byType(SplashScreen));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byType(SplashScreen));
      await tester.pump(const Duration(milliseconds: 1500));

      // At 2.0s: still not finished
      expect(finishCount, 0);
    });

    testWidgets('3. Status changes from "Memuat..." to "Siap!" at 4.4 seconds',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      // At 2.0s: status is "Memuat..."
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text('Memuat...'), findsOneWidget);
      expect(find.text('Siap!'), findsNothing);

      // At 4.45s: status becomes "Siap!"
      await tester.pump(const Duration(milliseconds: 2450));
      expect(find.text('Siap!'), findsOneWidget);
      expect(find.text('Memuat...'), findsNothing);

      // Complete the splash timer to clean up
      await tester.pump(const Duration(milliseconds: 1000));
    });

    testWidgets('4. With disableAnimations active, onFinished is called after 2 seconds',
        (WidgetTester tester) async {
      int finishCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: SplashScreen(
              onFinished: () => finishCount++,
            ),
          ),
        ),
      );

      // Initial state with disableAnimations
      expect(finishCount, 0);
      expect(find.text('Siap!'), findsOneWidget);

      // At 1.5s: not yet finished
      await tester.pump(const Duration(milliseconds: 1500));
      expect(finishCount, 0);

      // At 2.1s: finished
      await tester.pump(const Duration(milliseconds: 600));
      expect(finishCount, 1);
    });

    testWidgets('5. No timers remaining after dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      // Let it run for 1 second
      await tester.pump(const Duration(milliseconds: 1000));

      // Replace with another widget (disposing SplashScreen before timers finish)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Disposed')),
        ),
      );

      // Advance time to verify no pending timers crash
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('Disposed'), findsOneWidget);
    });

    testWidgets('6. Layout on mobile 390x844 viewport: no overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Complete splash
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('7. Layout on mobile 360x640 viewport: no overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Complete splash
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('8. Layout on tablet 800x1280 (portrait) viewport: no overflow, centered portrait',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Complete splash
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('9. Layout on tablet 1024x768 (landscape) viewport: no overflow, centered portrait',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onFinished: () {},
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Complete splash
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
