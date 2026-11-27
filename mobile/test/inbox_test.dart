import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/inbox/models/message_item.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/arsip_screen.dart';
import 'package:mobile/features/inbox/screens/inbox_screen.dart';
import 'package:mobile/features/inbox/screens/pesan_screen.dart';
import 'package:mobile/features/inbox/screens/story_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/inbox/utils/relative_time.dart';
import 'package:mobile/features/inbox/widgets/message_row_card.dart';
import 'package:mobile/features/links/screens/links_screen.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/widgets/phone_preview.dart';
import 'package:mobile/features/shell/main_shell.dart';
import 'package:mobile/features/shell/widgets/app_bottom_nav.dart';

void main() {
  group('formatRelativeTime', () {
    final now = DateTime(2026, 11, 26, 12, 0, 0);

    test('returns Baru saja for < 1 minute', () {
      expect(formatRelativeTime(now, now: now), 'Baru saja');
      expect(
        formatRelativeTime(now.subtract(const Duration(seconds: 59)), now: now),
        'Baru saja',
      );
    });

    test('returns N menit lalu for 1..59 minutes', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 1)), now: now),
        '1 menit lalu',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 12)), now: now),
        '12 menit lalu',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(minutes: 59)), now: now),
        '59 menit lalu',
      );
    });

    test('returns N jam lalu for 1..23 hours', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 1)), now: now),
        '1 jam lalu',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(hours: 23)), now: now),
        '23 jam lalu',
      );
    });

    test('returns Kemarin for 1 day and N hari lalu for 2+ days', () {
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 1)), now: now),
        'Kemarin',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 2)), now: now),
        '2 hari lalu',
      );
      expect(
        formatRelativeTime(now.subtract(const Duration(days: 5)), now: now),
        '5 hari lalu',
      );
    });
  });

  group('MockMessageRepository', () {
    late MockMessageRepository repo;

    setUp(() {
      repo = MockMessageRepository.instance;
      repo.resetToDefaults();
    });

    test('seed has inboxMessageCount = 5 and unreadCount = 2 sorted descending',
        () {
      expect(repo.inboxMessageCount, 5);
      expect(repo.unreadCount, 2);
      expect(repo.allInboxMessages.length, 5);
      expect(repo.unreadMessages.length, 2);
      expect(repo.archivedMessages.length, 0);

      for (int i = 0; i < repo.allInboxMessages.length - 1; i++) {
        expect(
          repo.allInboxMessages[i].createdAt
              .isAfter(repo.allInboxMessages[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('markRead, archive, unarchive, and addMessage update derived counts',
        () async {
      await repo.markRead('msg-1');
      expect(repo.unreadCount, 1);
      expect(repo.inboxMessageCount, 5);
      expect(repo.getById('msg-1')!.isArchived, isFalse);

      await repo.archive('msg-2');
      expect(repo.getById('msg-2')!.isArchived, isTrue);
      expect(repo.getById('msg-2')!.isRead, isTrue);
      expect(repo.inboxMessageCount, 4);
      expect(repo.unreadCount, 0);
      expect(repo.archivedMessages.length, 1);

      await repo.unarchive('msg-2');
      expect(repo.getById('msg-2')!.isArchived, isFalse);
      expect(repo.getById('msg-2')!.isRead, isTrue);
      expect(repo.inboxMessageCount, 5);
      expect(repo.unreadCount, 0);
      expect(repo.archivedMessages.length, 0);

      await repo.addMessage(
        MessageItem(
          id: 'msg-new',
          nglId: 'mock-2',
          nglName: 'fess angkatan',
          text: 'pesan masuk baru',
          createdAt: DateTime.now().add(const Duration(seconds: 5)),
          isRead: false,
          isArchived: false,
        ),
      );
      expect(repo.inboxMessageCount, 6);
      expect(repo.unreadCount, 1);
      expect(repo.allInboxMessages.first.id, 'msg-new');
      expect(repo.unreadCountForNgl('mock-2'), 1);
      expect(repo.messageCountForNgl('mock-2'), 2);
    });
  });

  group('Inbox, Pesan, Story, Arsip & Cross-Screen Sync', () {
    late MockNglRepository nglRepo;
    late MockMessageRepository msgRepo;
    late FakeStoryExportService exportService;

    setUp(() {
      nglRepo = MockNglRepository.instance;
      nglRepo.resetToDefaults();
      msgRepo = nglRepo.defaultMessageRepository;
      exportService = FakeStoryExportService();
    });

    testWidgets(
        'Inbox renders 3 tabs, unread/read cards, inactive NGL message, and empty state',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: nglRepo,
            messageRepository: msgRepo,
            storyExportService: exportService,
            initialTab: 2,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('INBOX'), findsWidgets);
      expect(find.text('2 BARU'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Belum dibaca'), findsOneWidget);
      expect(find.text('Arsip'), findsOneWidget);

      expect(find.byType(MessageRowCard), findsNWidgets(5));
      expect(find.text('Pesan baru!'), findsNWidgets(2));
      expect(find.text('NGL lama (nonaktif)'), findsOneWidget);

      // Unread body is hidden in Inbox row; read body preview is shown
      expect(
        find.text(
          'semangat ujiannya ya! kamu pasti bisa, jangan lupa istirahat.',
        ),
        findsNothing,
      );
      expect(
        find.text('makasih sudah jadi teman seangkatan yang seru banget!'),
        findsOneWidget,
      );

      // Switch to Belum dibaca
      await tester.tap(find.text('Belum dibaca'));
      await tester.pump();
      expect(find.byType(MessageRowCard), findsNWidgets(2));

      // Switch to Arsip (empty initially -> shared empty state)
      await tester.tap(find.text('Arsip'));
      await tester.pump();
      expect(find.byType(MessageRowCard), findsNothing);
      expect(find.text('Masih sepi di sini'), findsOneWidget);
      expect(
        find.text('Bagikan link-mu biar pesan rahasia mulai berdatangan.'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Inbox loading & error state with Coba lagi button',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      msgRepo.setSimulatedState(loading: true);
      await tester.pumpWidget(
        MaterialApp(
          home: InboxScreen(
            username: 'solvera',
            messageRepository: msgRepo,
            nglRepository: nglRepo,
            storyExportService: exportService,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Sebentar, ya...'), findsOneWidget);

      msgRepo.setSimulatedState(loading: false, error: 'Koneksi terputus');
      await tester.pump();
      expect(find.text('Oops, ada yang nyangkut'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      expect(find.byType(MessageRowCard), findsNWidgets(5));
    });

    testWidgets(
        'End-to-end flow: Inbox -> Pesan (marks read & syncs Home/Link/Nav) -> Story -> Archive -> Restore',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: MainShell(
            username: 'solvera',
            repository: nglRepo,
            messageRepository: msgRepo,
            storyExportService: exportService,
            initialTab: 2,
          ),
        ),
      );
      await tester.pump();

      // Open Belum dibaca tab (so tab persistence is also tested)
      await tester.tap(find.text('Belum dibaca'));
      await tester.pump();
      expect(find.byType(MessageRowCard), findsNWidgets(2));

      // Tap songfess unread message (msg-2: second card) -> opens PesanScreen
      await tester.tap(find.byType(MessageRowCard).at(1));
      await tester.pumpAndSettle();

      expect(find.byType(PesanScreen), findsOneWidget);
      expect(find.byType(AppBottomNav), findsNothing);
      expect(find.text('PESAN'), findsWidgets);
      expect(find.text('ANONIM'), findsOneWidget);
      expect(find.text('Bergema Sampai Selamanya — Nadhif'), findsOneWidget);
      expect(
        find.text('lagu ini ngingetin aku sama waktu class meeting kemarin'),
        findsOneWidget,
      );

      // Opening Pesan marked msg-2 as read (unreadCount = 1)
      expect(msgRepo.unreadCount, 1);
      expect(msgRepo.inboxMessageCount, 5);

      // Go back -> still on Belum dibaca tab with 1 unread remaining
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(InboxScreen), findsOneWidget);
      expect(find.text('1 BARU'), findsOneWidget);
      expect(find.byType(MessageRowCard), findsOneWidget);

      // Open remaining unread message (msg-1) -> unreadCount becomes 0
      await tester.tap(find.byType(MessageRowCard).first);
      await tester.pumpAndSettle();
      expect(msgRepo.unreadCount, 0);

      // Open StoryScreen from PesanScreen
      await tester.tap(find.text('Buat story'));
      await tester.pumpAndSettle();
      expect(find.byType(StoryScreen), findsOneWidget);
      expect(find.byType(PhonePreview), findsOneWidget);

      // Save & Share invoke StoryExportService
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(exportService.saveCallCount, 1);

      await tester.ensureVisible(find.text('Bagikan ke Instagram Story'));
      await tester.tap(find.text('Bagikan ke Instagram Story'));
      await tester.pumpAndSettle();
      expect(exportService.shareCallCount, 1);

      // Sudah dipost -> confirm -> archive -> opens ArsipScreen
      await tester.ensureVisible(find.text('Sudah dipost'));
      await tester.tap(find.text('Sudah dipost'));
      await tester.pumpAndSettle();
      expect(find.text('Pindahkan ke Arsip?'), findsOneWidget);

      await tester.tap(find.text('Pindahkan'));
      await tester.pumpAndSettle();
      expect(find.byType(ArsipScreen), findsOneWidget);
      expect(find.text('1 PESAN'), findsOneWidget);
      expect(msgRepo.inboxMessageCount, 4);

      // Restore from ArsipScreen
      await tester.tap(find.text('Kembalikan ke Inbox'));
      await tester.pumpAndSettle();
      expect(msgRepo.inboxMessageCount, 5);
      expect(find.text('Arsip masih kosong'), findsOneWidget);

      // Pop ArsipScreen -> PesanScreen -> InboxScreen
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Kembali'));
      await tester.pumpAndSettle();

      // Badge N BARU hidden when unreadCount == 0
      expect(find.text('0 BARU'), findsNothing);
      expect(find.text('2 BARU'), findsNothing);
      expect(find.text('1 BARU'), findsNothing);

      // Check Beranda & Link synced to 5 inbox messages & 0 unread
      await tester.tap(find.text('Beranda'));
      await tester.pump();
      final homeFinder = find.byType(HomeScreen);
      expect(
        find.descendant(of: homeFinder, matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: homeFinder, matching: find.text('0')),
        findsOneWidget,
      );

      await tester.tap(find.text('Link'));
      await tester.pump();
      final linksFinder = find.byType(LinksScreen);
      expect(
        find.descendant(
          of: linksFinder,
          matching: find.text('2 pesan · semua sudah dibaca', findRichText: true),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: linksFinder,
          matching: find.textContaining('baru', findRichText: true),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'InboxScreen responsive without overflow at 360x640, 390x844, 430x932',
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
              repository: nglRepo,
              messageRepository: msgRepo,
              initialTab: 2,
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Overflow on InboxScreen at $size',
        );
      }
      addTearDown(tester.view.reset);
    });
  });
}
