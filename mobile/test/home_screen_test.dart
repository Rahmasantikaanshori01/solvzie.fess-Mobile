import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders with username', (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'solveratest', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('HALO,'), findsOneWidget);
      expect(find.text('@solveratest'), findsOneWidget);
    });

    testWidgets('avatar shows first letter of username uppercased',
        (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'wayan', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('stats show 0 for empty repository', (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'newuser', repository: repo),
        ),
      );
      await tester.pump();
      // All 3 stat cells should show 0
      expect(find.text('0'), findsNWidgets(3));
    });

    testWidgets('shows empty links state when no ngls', (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'newuser', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('Belum ada link'), findsOneWidget);
    });

    testWidgets('shows empty activity state when no data', (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'newuser', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('Belum ada aktivitas'), findsOneWidget);
    });

    testWidgets('shows NGL cards when repository has ngls', (tester) async {
      final repo = MockNglRepository.empty();
      await repo.addNgl(
        const NglItem(
          id: '1',
          name: 'fess kelas',
          slug: 'fess-kelas',
          link: 'https://solvzie.fess/@fess-kelas',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'tester', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('fess kelas'), findsOneWidget);
    });

    testWidgets('bottom nav shows Beranda selected', (tester) async {
      final repo = MockNglRepository.empty();
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(username: 'newuser', repository: repo),
        ),
      );
      await tester.pump();
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('no overflow on standard 390x844 and 360x640 screen sizes',
        (tester) async {
      final repo = MockNglRepository.instance..resetToDefaults();

      for (final size in const [Size(360, 640), Size(390, 844), Size(430, 932)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: HomeScreen(username: 'testuser', repository: repo),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull,
            reason: 'Overflow on size $size');
      }

      addTearDown(tester.view.reset);
    });
  });
}
