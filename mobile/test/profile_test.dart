import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/screens/lupa_password_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/profile/state/profile_notifier.dart';
import 'package:mobile/features/profile/widgets/logout_dialog.dart';
import 'package:mobile/features/profile/widgets/password_field.dart';
import 'package:mobile/features/shell/main_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MockAccountRepository accountRepo;
  late MockNglRepository nglRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    accountRepo = MockAccountRepository.isolated(
      username: 'solvera',
      email: 'solvera@solvzie.fess',
      password: 'pass123',
    );
    nglRepo = MockNglRepository.instance..resetToDefaults();
  });

  group('1. Tampilan Profil & Keamanan Hash Password', () {
    testWidgets(
        'Profil menampilkan username, email, Akun bersama, dan huruf awal avatar',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            username: 'solvera',
            accountRepository: accountRepo,
            preferences: prefs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PROFIL'), findsOneWidget);
      expect(find.text('KAMU'), findsOneWidget);
      expect(find.text('@solvera'), findsOneWidget);
      expect(find.text('solvera@solvzie.fess'), findsOneWidget);
      expect(find.text('Akun bersama'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    test('Password tidak pernah disimpan polos (SHA-256 hash)', () {
      expect(accountRepo.account.passwordHash, isNot('pass123'));
      expect(
        accountRepo.account.passwordHash,
        hashAccountPassword('pass123'),
      );
      expect(accountRepo.account.passwordHash.length, 64);
    });
  });

  group('2. Pengaturan Notifikasi & Persistensi SharedPreferences', () {
    testWidgets(
        'Toggle notifikasi mengubah nilai, bertahan setelah state dibuat ulang, dan tampilkan toast',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            username: 'solvera',
            accountRepository: accountRepo,
            preferences: prefs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Kabar saat pesan baru masuk'), findsOneWidget);

      final switchFinder = find.bySemanticsLabel('Notifikasi pesan baru');
      expect(switchFinder, findsOneWidget);

      // Tap -> off
      await tester.tap(switchFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Notifikasi dimatikan'), findsOneWidget);
      expect(prefs.getBool(kPesanBaruNotifPrefKey), isFalse);

      // Recreate state / notifier from persisted prefs
      final recreatedNotifier = ProfileNotifier(
        repository: accountRepo,
        preferences: prefs,
      );
      expect(recreatedNotifier.pesanBaruNotif, isFalse);
      recreatedNotifier.dispose();

      // Re-mount ProfileScreen cleanly and verify toggle stays false then toggle back on
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            username: 'solvera',
            accountRepository: accountRepo,
            preferences: prefs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Notifikasi pesan baru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Notifikasi aktif'), findsOneWidget);
      expect(prefs.getBool(kPesanBaruNotifPrefKey), isTrue);
    });
  });

  group('3. Edit Profil & Sinkronisasi ke Home tanpa Restart', () {
    testWidgets(
        'Validasi tiap kolom, penolakan duplikat, "Tidak ada perubahan", dan update Home langsung',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: nglRepo,
            accountRepository: accountRepo,
            preferences: prefs,
            initialTab: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka accordion Edit profil
      await tester.tap(find.text('Edit profil'));
      await tester.pumpAndSettle();

      // Tidak ada perubahan -> toast "Tidak ada perubahan"
      await tester.ensureVisible(find.text('Simpan perubahan'));
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Tidak ada perubahan'), findsOneWidget);

      final usernameField = find.widgetWithText(TextField, 'username kamu');
      final emailField = find.widgetWithText(TextField, 'nama@email.com');

      // Username terlalu pendek & email invalid
      await tester.enterText(usernameField, 'ab');
      await tester.enterText(emailField, 'salah-email');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan perubahan'));
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Minimal 3 karakter, ya.'), findsOneWidget);
      expect(find.text('Masukkan email yang valid.'), findsOneWidget);

      // Error hilang saat field diperbaiki
      await tester.enterText(usernameField, 'budi_keren');
      await tester.pump();
      expect(find.text('Minimal 3 karakter, ya.'), findsNothing);

      await tester.enterText(emailField, 'budi@solvzie.fess');
      await tester.pump();
      expect(find.text('Masukkan email yang valid.'), findsNothing);

      // Username & email sudah dipakai (seeded 'naya' / 'naya@solvzie.fess')
      await tester.enterText(usernameField, 'naya');
      await tester.enterText(emailField, 'naya@solvzie.fess');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan perubahan'));
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Username sudah dipakai'), findsOneWidget);
      expect(find.text('Email sudah dipakai'), findsOneWidget);

      // Isi data valid & unik -> berhasil
      await tester.enterText(usernameField, 'budi_keren');
      await tester.enterText(emailField, 'budi@solvzie.fess');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan perubahan'));
      await tester.tap(find.text('Simpan perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Profil diperbarui'), findsOneWidget);
      expect(find.text('@budi_keren'), findsWidgets);
      expect(find.text('budi@solvzie.fess'), findsOneWidget);
      expect(find.text('B'), findsWidgets);

      // Pindah ke Home -> sapaan & avatar langsung berubah tanpa restart
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      final homeFinder = find.byType(HomeScreen);
      expect(
        find.descendant(of: homeFinder, matching: find.text('@budi_keren')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('B')),
        findsOneWidget,
      );
    });
  });

  group('4. Ubah Password & Login Ulang dengan Password Baru', () {
    testWidgets(
        'Tolak password lama salah / < 6 / konfirmasi beda / sama dengan lama; sukses bersihkan field & berlaku untuk Login',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: nglRepo,
            accountRepository: accountRepo,
            preferences: prefs,
            initialTab: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ubah password'));
      await tester.pumpAndSettle();

      final oldField =
          find.widgetWithText(TextField, 'masukkan password lama');
      final newField = find.widgetWithText(TextField, 'minimal 6 karakter');
      final confirmField =
          find.widgetWithText(TextField, 'ulangi password baru');

      // 1. Password lama salah, password baru < 6, konfirmasi beda
      await tester.enterText(oldField, 'salah123');
      await tester.enterText(newField, '123');
      await tester.enterText(confirmField, '456');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan password'));
      await tester.tap(find.text('Simpan password'));
      await tester.pumpAndSettle();

      expect(find.text('Password lama salah'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter.'), findsOneWidget);
      expect(find.text('Password belum sama.'), findsOneWidget);

      // 2. Password baru sama dengan lama
      await tester.enterText(oldField, 'pass123');
      await tester.enterText(newField, 'pass123');
      await tester.enterText(confirmField, 'pass123');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan password'));
      await tester.tap(find.text('Simpan password'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password baru harus beda dari yang lama'),
        findsOneWidget,
      );

      // 3. Password valid & unik -> sukses, kolom dikosongkan, tutup accordion, toast tampil
      await tester.enterText(oldField, 'pass123');
      await tester.enterText(newField, 'baru1234');
      await tester.enterText(confirmField, 'baru1234');
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan password'));
      await tester.tap(find.text('Simpan password'));
      await tester.pumpAndSettle();

      expect(find.text('Password berhasil diubah'), findsOneWidget);
      // Bagian menutup otomatis -> field PasswordField tidak lagi tampak
      expect(find.byType(PasswordField), findsNothing);

      // Buka lagi untuk verifikasi kolom sudah dikosongkan
      await tester.tap(find.text('Ubah password'));
      await tester.pumpAndSettle();
      for (final tf in tester.widgetList<TextField>(find.byType(TextField))) {
        expect(tf.controller?.text ?? '', isEmpty);
      }

      // Tunggu snackbar toast selesai lalu logout & tes login ulang
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, logout'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      final loginFields = find.byType(TextField);
      await tester.enterText(loginFields.first, 'solvera');
      await tester.enterText(loginFields.last, 'pass123');
      await tester.pump();
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Username atau password salah.'), findsOneWidget);
      expect(find.byType(MainShell), findsNothing);

      await tester.enterText(loginFields.last, 'baru1234');
      await tester.pump();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);
    });
  });

  group('5. Hanya Satu Accordion Terbuka dalam Satu Waktu', () {
    testWidgets('Membuka Ubah password menutup Edit profil dan sebaliknya',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            username: 'solvera',
            accountRepository: accountRepo,
            preferences: prefs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka Edit profil
      await tester.tap(find.text('Edit profil'));
      await tester.pumpAndSettle();
      expect(find.text('Simpan perubahan'), findsOneWidget);
      expect(find.text('Simpan password'), findsNothing);

      // Buka Ubah password -> Edit profil otomatis tertutup
      await tester.tap(find.text('Ubah password'));
      await tester.pumpAndSettle();
      expect(find.text('Simpan perubahan'), findsNothing);
      expect(find.text('Simpan password'), findsOneWidget);

      // Ketuk Ubah password lagi -> menutup semua
      await tester.tap(find.text('Ubah password'));
      await tester.pumpAndSettle();
      expect(find.text('Simpan perubahan'), findsNothing);
      expect(find.text('Simpan password'), findsNothing);
    });
  });

  group('6. Dialog & Alur Logout', () {
    testWidgets(
        'Dialog tampil dengan ikon & 2 tombol; Batal/ketuk area gelap batal; Ya, logout ke Login tanpa bisa back',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: nglRepo,
            accountRepository: accountRepo,
            preferences: prefs,
            initialTab: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka dialog logout
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(LogoutDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LogoutDialog),
          matching: find.byIcon(Icons.logout_rounded),
        ),
        findsOneWidget,
      );
      expect(find.text('Yakin mau logout?'), findsOneWidget);
      expect(
        find.text('Kamu perlu masuk lagi untuk melihat pesan.'),
        findsOneWidget,
      );
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Ya, logout'), findsOneWidget);

      // Tap Batal -> tidak logout
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.byType(LogoutDialog), findsNothing);
      expect(accountRepo.isSignedIn, isTrue);
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Buka dialog lagi -> tap area gelap di luar kartu
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(LogoutDialog), findsNothing);
      expect(accountRepo.isSignedIn, isTrue);

      // Buka dialog lagi -> tap "Ya, logout"
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, logout'));
      await tester.pumpAndSettle();

      expect(accountRepo.isSignedIn, isFalse);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainShell), findsNothing);

      // Tidak bisa kembali ke Profil via back stack
      final NavigatorState nav = tester.state(find.byType(Navigator));
      expect(nav.canPop(), isFalse);
    });
  });

  group('7. Lupa Password', () {
    testWidgets(
        'Navigasi dari Login, tolak email invalid, dan email valid mana pun tampilkan pesan sukses yang sama',
        (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(accountRepository: accountRepo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lupa password?'));
      await tester.pumpAndSettle();
      expect(find.byType(LupaPasswordScreen), findsOneWidget);
      expect(find.text('LUPA PASSWORD?'), findsOneWidget);

      // Submit kosong -> error
      await tester.tap(find.text('Kirim link reset'));
      await tester.pump();
      expect(find.text('Masukkan email yang valid.'), findsOneWidget);

      // Email invalid
      await tester.enterText(find.byType(TextField), 'bukan-email');
      await tester.pump();
      expect(find.text('Masukkan email yang valid.'), findsNothing);
      await tester.tap(find.text('Kirim link reset'));
      await tester.pump();
      expect(find.text('Masukkan email yang valid.'), findsOneWidget);

      // Email tidak terdaftar -> pesan sukses generik
      await tester.enterText(find.byType(TextField), 'tidak.ada@contoh.id');
      await tester.pump();
      await tester.tap(find.text('Kirim link reset'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
      expect(find.text('Cek emailmu'), findsOneWidget);
      expect(
        find.text(
          'Kalau email ini terdaftar, kami kirim link reset ke kotak masukmu.',
        ),
        findsOneWidget,
      );
      expect(find.text('Kembali ke login'), findsOneWidget);

      // Kembali ke login
      await tester.tap(find.text('Kembali ke login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      // Buka lagi dengan email terdaftar -> pesan sukses IDENTIK
      await tester.tap(find.text('Lupa password?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'solvera@solvzie.fess');
      await tester.pump();
      await tester.tap(find.text('Kirim link reset'));
      await tester.pumpAndSettle();

      expect(find.text('Cek emailmu'), findsOneWidget);
      expect(
        find.text(
          'Kalau email ini terdaftar, kami kirim link reset ke kotak masukmu.',
        ),
        findsOneWidget,
      );
    });
  });

  group('8. Responsivitas Tanpa Overflow (360x640, 390x844, 430x932)', () {
    testWidgets(
        'ProfileScreen (termasuk accordion & LogoutDialog) & LupaPasswordScreen bebas overflow',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
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
              repository: nglRepo,
              accountRepository: accountRepo,
              preferences: prefs,
              initialTab: 3,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'ProfileScreen overflow on $size',
        );

        await tester.tap(find.text('Edit profil'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Edit profil overflow on $size',
        );

        await tester.tap(find.text('Ubah password'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Ubah password overflow on $size',
        );

        await tester.ensureVisible(find.text('Logout'));
        await tester.tap(find.text('Logout'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'LogoutDialog overflow on $size',
        );
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          const MaterialApp(home: LupaPasswordScreen()),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'LupaPasswordScreen overflow on $size',
        );
      }
      addTearDown(tester.view.reset);
    });
  });
}
