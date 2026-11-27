import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/links/screens/links_screen.dart';
import 'package:mobile/features/links/widgets/link_card.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/screens/buat_ngl_screen.dart';
import 'package:mobile/features/ngl_create/screens/pratinjau_screen.dart';
import 'package:mobile/features/ngl_create/screens/tema_screen.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';
import 'package:mobile/features/shell/main_shell.dart';

final Uint8List _kSampleImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  late MockNglRepository repository;
  late FakeImagePickerService fakePicker;

  setUp(() {
    repository = MockNglRepository.instance;
    repository.resetToDefaults();
    fakePicker = FakeImagePickerService(
      nextResult: PickedTemplateImage(
        id: 'picked-barca',
        bytes: _kSampleImage,
        name: 'barca.png',
      ),
    );
  });

  group('Links, Home Dinamis, & Shell Integration Tests', () {
    testWidgets(
        '4. Menekan "Link" di nav membuka LinksScreen, bukan Buat NGL, dan tidak ada teks Daftar Link (Sementara)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: repository,
            imagePickerService: fakePicker,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Link'));
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, 1);
      expect(find.byType(LinksScreen), findsOneWidget);
      expect(find.byType(BuatNglScreen), findsNothing);
      expect(find.text('Daftar Link (Sementara)'), findsNothing);
      expect(find.text('LINK'), findsWidgets);
      expect(find.text('${repository.activeNglCount} AKTIF'), findsOneWidget);
    });

    testWidgets(
        '5. Skenario penuh: Home -> Buat NGL (foto) -> Tema (foto tampil & ubah posisi) -> Konfirmasi -> Pratinjau -> Simpan NGL -> Link tab (NGL baru paling atas) -> Beranda (NGL aktif N+1, pesan tetap)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final initialActiveCount = repository.activeNglCount; // 3
      final initialTotalMessages = repository.totalMessageCount; // 33
      final initialOldIds = repository.ngls.map((n) => n.id).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: repository,
            imagePickerService: fakePicker,
          ),
        ),
      );
      await tester.pump();

      final homeFinder = find.byType(HomeScreen);
      final linksFinder = find.byType(LinksScreen);

      // Home shows N aktif & 2 NGL terbaru di Link kamu
      expect(
        find.descendant(of: homeFinder, matching: find.text('$initialActiveCount')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('$initialTotalMessages')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('fess kelas 12')),
        findsWidgets,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('fess angkatan')),
        findsOneWidget,
      );

      // Tap "+ Buat NGL baru"
      await tester.tap(find.text('Buat NGL baru'));
      await tester.pumpAndSettle();
      expect(find.byType(BuatNglScreen), findsOneWidget);

      // Ketik nama & tunggu link tersedia
      await tester.enterText(
        find.widgetWithText(TextField, 'contoh: fess kelas 12'),
        'fess barca baru',
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('✓ Link tersedia'), findsOneWidget);

      // Tambah foto (fake picker) -> counter 1/5
      await tester.tap(find.text('+ Add image'));
      await tester.pump();
      expect(find.text('1/5'), findsOneWidget);

      // Lanjut aktif -> buka Tema
      await tester.ensureVisible(find.text('Lanjut'));
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.byType(TemaScreen), findsOneWidget);

      // Tema menampilkan foto di pratinjau seketika
      final temaPreview = find.byType(PhonePreview);
      expect(
        find.descendant(of: temaPreview, matching: find.byType(Image)),
        findsOneWidget,
      );

      // Ubah posisi bubble ke Atas
      await tester.ensureVisible(find.text('Atas'));
      await tester.tap(find.text('Atas'));
      await tester.pump();
      expect(
        tester.widget<PhonePreview>(temaPreview).bubblePosition,
        BubblePosition.atas,
      );

      // Tap Simpan -> muncul konfirmasi
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Template ini sudah polos tanpa teks?'), findsOneWidget);

      // Tap "Sudah polos" -> buka Pratinjau
      await tester.tap(find.text('Sudah polos'));
      await tester.pumpAndSettle();
      expect(find.byType(PratinjauScreen), findsOneWidget);

      // Tap "Simpan NGL" -> kembali ke shell tab Link
      await tester.ensureVisible(find.text('Simpan NGL'));
      await tester.tap(find.text('Simpan NGL'));
      await tester.pumpAndSettle();

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, 1);
      expect(
        find.descendant(
          of: linksFinder,
          matching: find.text('${initialActiveCount + 1} AKTIF'),
        ),
        findsOneWidget,
      );

      // NGL baru di paling atas dengan fotonya, NGL lama tidak berubah
      final linkCards =
          tester.widgetList<LinkCard>(find.byType(LinkCard)).toList();
      expect(linkCards.first.ngl.name, 'fess barca baru');
      expect(linkCards.first.ngl.backgroundType, BackgroundType.photo);
      expect(linkCards.first.ngl.photoBytes, isNotNull);

      final repoNgls = repository.ngls;
      expect(repoNgls.length, initialOldIds.length + 1);
      expect(repoNgls.first.name, 'fess barca baru');
      for (int i = 0; i < initialOldIds.length; i++) {
        expect(repoNgls[i + 1].id, initialOldIds[i]);
      }

      // Pastikan thumbnail pada kartu pertama merender Image.memory
      expect(
        find.descendant(
          of: find.byType(LinkCard).first,
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );

      // Pindah ke tab Beranda -> NGL aktif = N+1, Link kamu posisi 1 = NGL baru, total pesan tetap
      await tester.tap(find.text('Beranda'));
      await tester.pump();

      expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
        0,
      );
      expect(
        find.descendant(
          of: homeFinder,
          matching: find.text('${initialActiveCount + 1}'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: homeFinder,
          matching: find.text('$initialTotalMessages'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('fess barca baru')),
        findsOneWidget,
      );
      // 2 terbaru: fess barca baru & fess kelas 12 (fess angkatan tergeser keluar dari top 2)
      expect(
        find.descendant(of: homeFinder, matching: find.text('fess angkatan')),
        findsNothing,
      );
    });

    testWidgets(
        '6. Toggle aktif mengubah badge "N AKTIF" di Link & angka di Home; soft delete menghilangkan kartu & mengurangi angka di Home sambil menjaga pesan',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: repository,
            initialTab: 1, // Mulai di Link tab
          ),
        ),
      );
      await tester.pump();

      final homeFinder = find.byType(HomeScreen);
      final linksFinder = find.byType(LinksScreen);

      expect(
        find.descendant(of: linksFinder, matching: find.text('3 AKTIF')),
        findsOneWidget,
      );
      final initialMessages = repository.totalMessageCount;

      // Toggle kartu pertama ("fess kelas 12") menjadi nonaktif
      await tester.tap(find.bySemanticsLabel('Nonaktifkan fess kelas 12'));
      await tester.pump();

      expect(
        find.descendant(of: linksFinder, matching: find.text('2 AKTIF')),
        findsOneWidget,
      );

      // Cek Home angka berkurang menjadi 2
      await tester.tap(find.text('Beranda'));
      await tester.pump();
      expect(
        find.descendant(of: homeFinder, matching: find.text('2')),
        findsNWidgets(2), // active=2 dan unread=2
      );

      // Kembali ke Link dan hapus NGL kedua ("fess angkatan" yang masih aktif)
      await tester.tap(find.text('Link'));
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Opsi fess angkatan'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus NGL'));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat pesan tetap tersimpan.'), findsOneWidget);
      await tester.tap(find.text('Hapus NGL').last);
      await tester.pumpAndSettle();

      // Kartu "fess angkatan" hilang dari daftar
      expect(
        find.descendant(of: linksFinder, matching: find.text('fess angkatan')),
        findsNothing,
      );
      expect(
        find.descendant(of: linksFinder, matching: find.text('1 AKTIF')),
        findsOneWidget,
      );

      // Cek Home: NGL aktif = 1, total pesan tetap sama
      await tester.tap(find.text('Beranda'));
      await tester.pump();
      expect(
        find.descendant(of: homeFinder, matching: find.text('1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('$initialMessages')),
        findsOneWidget,
      );
    });

    testWidgets(
        '7. LinksScreen responsif tanpa overflow di 360x640, 390x844, 430x932',
        (tester) async {
      for (final size in const [
        Size(360, 640),
        Size(390, 844),
        Size(430, 932),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MainShell(
              username: 'solvera',
              repository: repository,
              initialTab: 1,
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Overflow on LinksScreen at $size',
        );
      }
      addTearDown(tester.view.reset);
    });
  });
}
