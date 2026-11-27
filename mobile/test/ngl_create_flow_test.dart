import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/links/screens/links_screen.dart';
import 'package:mobile/features/ngl_create/models/ngl_draft.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/screens/buat_ngl_screen.dart';
import 'package:mobile/features/ngl_create/screens/pratinjau_screen.dart';
import 'package:mobile/features/ngl_create/screens/tema_screen.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';

// 1x1 valid transparent PNG bytes to avoid ImageCodec exceptions in tests
final Uint8List _kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

Uint8List _createDummyBytes(int seed) {
  return _kTransparentImage;
}

void main() {
  late MockNglRepository repository;
  late FakeImagePickerService fakePicker;
  late NglCreateController controller;

  setUp(() {
    repository = MockNglRepository();
    repository.resetToDefaults();
    fakePicker = FakeImagePickerService();
    controller = NglCreateController(
      repository: repository,
      imagePickerService: fakePicker,
      username: 'solvera',
    );
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Alur Buat NGL - Widget & Flow Tests', () {
    // ── Test 1: Validasi Tombol Lanjut ──
    testWidgets(
        '1. Lanjut redup jika nama kosong / link belum tersedia, aktif jika valid',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestApp(BuatNglScreen(controller: controller)));
      await tester.pump();

      expect(controller.isCanProceed, isFalse);

      final nameField = find.widgetWithText(TextField, 'contoh: fess kelas 12');
      await tester.enterText(nameField, 'fess baru kita');
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.isCanProceed, isFalse);

      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.linkStatus, LinkStatus.available);
      expect(controller.isCanProceed, isTrue);

      final slugField = find.widgetWithText(TextField, 'fess-baru-kita');
      await tester.enterText(slugField, 'solvzie');
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.linkStatus, LinkStatus.taken);
      expect(controller.isCanProceed, isFalse);
    });

    // ── Test 2: Add Image & Delete Image dengan Dialog Konfirmasi (M5) ──
    testWidgets(
        '2. Delete image menampilkan dialog; Batal tidak mengubah apa pun; Hapus menghapus foto terpilih saja',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      fakePicker.nextResult = PickedTemplateImage(
        id: 'img-1',
        bytes: _createDummyBytes(1),
        name: 'foto1.png',
      );

      await tester.pumpWidget(createTestApp(BuatNglScreen(controller: controller)));
      await tester.pump();

      expect(find.text('0/5'), findsOneWidget);

      // Delete image nonaktif saat gradasi terpilih -> tidak buka dialog
      expect(controller.draftBackgroundType, BackgroundType.gradient);
      await tester.tap(find.text('Delete image'));
      await tester.pump();
      expect(find.text('Hapus foto ini dari template?'), findsNothing);

      // Tambah foto 1 & foto 2
      await tester.tap(find.text('+ Add image'));
      await tester.pump();
      expect(find.text('1/5'), findsOneWidget);

      fakePicker.nextResult = PickedTemplateImage(
        id: 'img-2',
        bytes: _createDummyBytes(2),
        name: 'foto2.png',
      );
      await tester.tap(find.text('+ Add image'));
      await tester.pump();
      expect(find.text('2/5'), findsOneWidget);
      expect(controller.draftPhotoIndex, 1);

      // Hasil null tidak mengubah apa pun
      fakePicker.nextResult = null;
      await tester.tap(find.text('+ Add image'));
      await tester.pump();
      expect(controller.photos.length, 2);

      // Tekan Delete image -> muncul dialog konfirmasi
      await tester.tap(find.text('Delete image'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus foto ini dari template?'), findsOneWidget);
      expect(
        find.text(
            'Foto akan dihapus dari daftar Template saya. Pilihan kembali ke Gradasi acak, dan NGL lain tidak berubah.'),
        findsOneWidget,
      );

      // Tekan "Batal" -> tidak mengubah apa pun
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus foto ini dari template?'), findsNothing);
      expect(controller.photos.length, 2);
      expect(controller.draftBackgroundType, BackgroundType.photo);
      expect(controller.draftPhotoIndex, 1);

      // Tekan Delete image lagi -> tekan "Hapus" -> menghapus foto terpilih saja & kembali ke gradasi
      await tester.tap(find.text('Delete image'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(controller.photos.length, 1);
      expect(controller.photos.first.id, 'img-1');
      expect(controller.draftBackgroundType, BackgroundType.gradient);
      expect(find.text('1/5'), findsOneWidget);
    });

    // ── Test 3: Batas maksimal 5/5 foto ──
    testWidgets('3. Batas maksimal 5 foto menampilkan SnackBar Maksimal 5 foto',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestApp(BuatNglScreen(controller: controller)));
      await tester.pump();

      for (int i = 1; i <= 5; i++) {
        fakePicker.nextResult = PickedTemplateImage(
          id: 'img-$i',
          bytes: _createDummyBytes(i),
          name: 'foto$i.png',
        );
        await tester.tap(find.text('+ Add image'));
        await tester.pump();
      }
      expect(find.text('5/5'), findsOneWidget);

      await tester.tap(find.text('+ Add image'));
      await tester.pump();
      expect(find.text('Maksimal 5 foto'), findsOneWidget);
      expect(controller.photos.length, 5);
    });

    // ── Test 4: Pilihan Warna saat Foto Terpilih ──
    testWidgets(
        '4. Saat foto terpilih, menekan pilihan warna menampilkan "Hanya untuk gradasi" dan tidak mengubah state',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      fakePicker.nextResult = PickedTemplateImage(
        id: 'img-1',
        bytes: _createDummyBytes(1),
        name: 'foto1.png',
      );
      await controller.pickAndAddPhoto();
      expect(controller.draftBackgroundType, BackgroundType.photo);

      await tester.pumpWidget(createTestApp(TemaScreen(controller: controller)));
      await tester.pump();

      final initialGradient = controller.gradientKey;

      await tester.tap(find.text('Purple pop'));
      await tester.pump();

      expect(find.text('Hanya untuk gradasi'), findsOneWidget);
      expect(controller.gradientKey, initialGradient);
    });

    // ── Test 5 (M1): Pratinjau Tema menampilkan foto seketika & kembali ke gradasi ──
    testWidgets(
        '5. Di Tema, memilih foto menampilkan Image.memory di pratinjau seketika; memilih gradasi / Delete image mengembalikan gradasi',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(createTestApp(TemaScreen(controller: controller)));
      await tester.pump();

      final previewFinder = find.byType(PhonePreview);
      // Awalnya gradasi -> tidak ada Image.memory di dalam PhonePreview
      expect(
        find.descendant(of: previewFinder, matching: find.byType(Image)),
        findsNothing,
      );

      // Tambah foto di Tema -> pratinjau SEKETIKA menampilkan Image.memory tanpa Simpan
      fakePicker.nextResult = PickedTemplateImage(
        id: 'img-barca',
        bytes: _createDummyBytes(9),
        name: 'barca.png',
      );
      await tester.tap(find.text('+ Add image'));
      await tester.pump();

      expect(
        find.descendant(of: previewFinder, matching: find.byType(Image)),
        findsOneWidget,
      );

      // Pilih Gradasi acak -> pratinjau kembali ke gradasi seketika
      await tester.tap(find.text('Gradasi acak'));
      await tester.pump();
      expect(
        find.descendant(of: previewFinder, matching: find.byType(Image)),
        findsNothing,
      );

      // Pilih tile foto lagi -> pratinjau tampilkan foto lagi
      final photoTile = find.descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Image),
      );
      await tester.tap(photoTile.first);
      await tester.pump();
      expect(
        find.descendant(of: previewFinder, matching: find.byType(Image)),
        findsOneWidget,
      );

      // Delete image -> Hapus -> pratinjau kembali ke gradasi seketika
      await tester.tap(find.text('Delete image'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(controller.draftBackgroundType, BackgroundType.gradient);
      expect(
        find.descendant(of: previewFinder, matching: find.byType(Image)),
        findsNothing,
      );
    });

    // ── Test 6: Konfirmasi Bottom Sheet untuk Foto ──
    testWidgets(
        '6. Simpan dengan foto memunculkan konfirmasi dulu; Pratinjau belum tampil sebelum "Sudah polos"',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      fakePicker.nextResult = PickedTemplateImage(
        id: 'img-1',
        bytes: _createDummyBytes(1),
        name: 'foto1.png',
      );
      await controller.pickAndAddPhoto();

      await tester.pumpWidget(createTestApp(TemaScreen(controller: controller)));
      await tester.pump();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Template ini sudah polos tanpa teks?'), findsOneWidget);
      expect(find.text('Sudah polos'), findsOneWidget);
      expect(find.text('BUBBLE OTOMATIS'), findsNothing);

      await tester.tap(find.text('Sudah polos'));
      await tester.pumpAndSettle();

      expect(find.text('BUBBLE OTOMATIS'), findsOneWidget);
    });

    // ── Test 7 (M2): Simpan NGL menambah NGL baru di paling atas dan membuka LinkScreen ──
    testWidgets(
        '7. Simpan NGL menambah satu NGL di paling atas dan membuka LinksScreen (bukan Daftar Link Sementara)',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final initialNgls = await repository.getNgls();
      final initialCount = initialNgls.length;
      final oldIds = initialNgls.map((n) => n.id).toList();

      controller.setName('fess baru kita');
      await tester.pump(const Duration(milliseconds: 500));
      expect(controller.linkStatus, LinkStatus.available);

      await tester.pumpWidget(createTestApp(PratinjauScreen(controller: controller)));
      await tester.pump();

      await tester.tap(find.text('Simpan NGL'));
      await tester.pumpAndSettle();

      // Membuka LinksScreen, bukan Daftar Link (Sementara)
      expect(find.byType(LinksScreen), findsOneWidget);
      expect(find.text('Daftar Link (Sementara)'), findsNothing);

      final updatedNgls = await repository.getNgls();
      expect(updatedNgls.length, initialCount + 1);
      expect(updatedNgls.first.name, 'fess baru kita');
      expect(updatedNgls.first.slug, 'fess-baru-kita');

      for (int i = 0; i < oldIds.length; i++) {
        expect(updatedNgls[i + 1].id, oldIds[i]);
      }
    });
  });
}
