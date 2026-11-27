import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/create_ngl/create_ngl_screen.dart';
import 'package:mobile/features/create_ngl/preview_ngl_screen.dart';
import 'package:mobile/features/create_ngl/theme_editor_screen.dart';
import 'package:mobile/features/create_ngl/widgets/message_bubble_widget.dart';
import 'package:mobile/features/create_ngl/widgets/phone_preview_widget.dart';
import 'package:mobile/features/create_ngl/widgets/template_confirmation_modal.dart';

void main() {
  group('CreateNglScreen Tests', () {
    testWidgets('renders all initial fields and labels correctly', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateNglScreen(username: 'solvera'),
        ),
      );
      await tester.pump();

      expect(find.text('BUAT'), findsWidgets);
      expect(find.text('NGL BARU'), findsOneWidget);
      expect(find.text('Nama NGL'), findsOneWidget);
      expect(find.text('Link NGL'), findsOneWidget);
      expect(find.text('Template saya'), findsOneWidget);
      expect(find.text('Gradasi acak'), findsOneWidget);
      expect(find.text('Add image'), findsNWidgets(2)); // tile and button
      expect(find.text('Delete image'), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);
    });

    testWidgets('auto-generates link slug from name and shows link tersedia', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateNglScreen(username: 'solvera'),
        ),
      );
      await tester.pump();

      // Enter name 'fess'
      final nameFinder = find.widgetWithText(TextField, 'contoh: fess kelas 12');
      await tester.enterText(nameFinder, 'fess');
      await tester.pump(const Duration(milliseconds: 600)); // debounce check (500ms)

      expect(find.text('Link tersedia'), findsOneWidget);
    });

    testWidgets('shows warning for reserved slug', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateNglScreen(username: 'solvera'),
        ),
      );
      await tester.pump();

      // Enter reserved name 'solvzie'
      final nameFinder = find.widgetWithText(TextField, 'contoh: fess kelas 12');
      await tester.enterText(nameFinder, 'solvzie');
      await tester.pump(const Duration(milliseconds: 600)); // debounce check (500ms)

      expect(find.text('Link sudah dipakai'), findsOneWidget);
    });

    testWidgets('navigates to ThemeEditorScreen when Lanjut is tapped', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: CreateNglScreen(username: 'solvera'),
        ),
      );
      await tester.pump();

      final nameFinder = find.widgetWithText(TextField, 'contoh: fess kelas 12');
      await tester.enterText(nameFinder, 'fess');
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('TEMA'), findsWidgets);
      expect(find.text('ATUR POSISI!'), findsOneWidget);
    });
  });

  group('ThemeEditorScreen Tests', () {
    testWidgets('shows template confirmation modal when clicking Simpan on ThemeEditorScreen', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeEditorScreen(
            username: 'solvera',
            name: 'fess kelas 12',
            slug: 'fess-kelas-12',
          ),
        ),
      );
      await tester.pump();

      // Tap Simpan button
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Template ini sudah polos tanpa teks?'), findsOneWidget);
      expect(find.text('Sudah polos'), findsOneWidget);

      // Tap 'Sudah polos' to dismiss modal
      await tester.tap(find.text('Sudah polos'));
      await tester.pumpAndSettle();

      expect(find.text('Template ini sudah polos tanpa teks?'), findsNothing);
    });
    testWidgets('renders position tabs and theme presets', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeEditorScreen(
            username: 'solvera',
            name: 'fess kelas 12',
            slug: 'fess-kelas-12',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('TEMA'), findsWidgets);
      expect(find.text('ATUR POSISI!'), findsOneWidget);
      expect(find.text('Atas'), findsOneWidget);
      expect(find.text('Tengah'), findsOneWidget);
      expect(find.text('Bawah'), findsOneWidget);
      expect(find.text('Candy sunset'), findsOneWidget);
      expect(find.text('Purple pop'), findsOneWidget);
      expect(find.text('Minty sky'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('changes active position when tab tapped', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeEditorScreen(
            username: 'solvera',
            name: 'fess kelas 12',
            slug: 'fess-kelas-12',
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Atas'));
      await tester.pump();

      // No crash, position is updated
      expect(find.text('Atas'), findsOneWidget);
    });
  });

  group('PreviewNglScreen Tests', () {
    testWidgets('renders phone preview and Simpan NGL button', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: PreviewNglScreen(
            username: 'solvera',
            name: 'fess kelas 12',
            slug: 'fess-kelas-12',
            theme: 'sunset',
            position: 'middle',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PRATINJAU'), findsWidgets);
      expect(find.text('BUBBLE OTOMATIS'), findsOneWidget);
      expect(find.text('Simpan NGL'), findsOneWidget);
      expect(find.text('Siap dipakai!'), findsOneWidget);
    });
  });
}
