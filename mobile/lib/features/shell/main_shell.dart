import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/home/home_screen.dart';
import 'package:mobile/features/inbox/repository/message_repository.dart';
import 'package:mobile/features/inbox/screens/inbox_screen.dart';
import 'package:mobile/features/inbox/services/story_export_service.dart';
import 'package:mobile/features/links/screens/links_screen.dart';
import 'package:mobile/features/ngl_create/repository/ngl_repository.dart';
import 'package:mobile/features/ngl_create/screens/buat_ngl_screen.dart';
import 'package:mobile/features/ngl_create/services/image_picker_service.dart';
import 'package:mobile/features/ngl_create/state/ngl_create_controller.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/shell/widgets/app_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main application shell preserving state across the 4 primary tabs
/// (Beranda, Link, Inbox, Profil) via [IndexedStack].
class MainShell extends StatefulWidget {
  static const String routeName = '/main-shell';

  final String username;
  final NglRepository? repository;
  final MessageRepository? messageRepository;
  final AccountRepository? accountRepository;
  final SharedPreferences? preferences;
  final ImagePickerService? imagePickerService;
  final StoryExportService? storyExportService;
  final int initialTab;

  const MainShell({
    super.key,
    required this.username,
    this.repository,
    this.messageRepository,
    this.accountRepository,
    this.preferences,
    this.imagePickerService,
    this.storyExportService,
    this.initialTab = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  NglRepository get _repository =>
      widget.repository ?? MockNglRepository.instance;

  MessageRepository get _messageRepository {
    if (widget.messageRepository != null) return widget.messageRepository!;
    final repo = _repository;
    if (repo is MockNglRepository) {
      return repo.defaultMessageRepository;
    }
    return MockMessageRepository.instance;
  }

  AccountRepository get _accountRepository =>
      widget.accountRepository ?? MockAccountRepository.instance;

  String get _activeUsername {
    if (_accountRepository.isSignedIn &&
        _accountRepository.account.username.isNotEmpty) {
      return _accountRepository.account.username;
    }
    return widget.username;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 3);
    if (widget.accountRepository == null &&
        _accountRepository is MockAccountRepository) {
      (_accountRepository as MockAccountRepository)
          .initFromLogin(widget.username);
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index > 3) return;
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  Future<void> _openCreateNgl() async {
    final controller = NglCreateController(
      repository: _repository,
      imagePickerService:
          widget.imagePickerService ?? DefaultImagePickerService(),
      username: _activeUsername,
    );

    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (context) => BuatNglScreen(controller: controller),
      ),
    );

    if (controller.isSaved && mounted) {
      setState(() => _currentIndex = 1);
    }
    controller.dispose();
  }

  void _handleLogout() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => _LoginWrapper(
          repository: widget.repository,
          messageRepository: widget.messageRepository,
          accountRepository: _accountRepository,
          preferences: widget.preferences,
          imagePickerService: widget.imagePickerService,
          storyExportService: widget.storyExportService,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double compositionWidth = size.width > 430.0 ? 430.0 : size.width;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: SplashColors.tealDeep,
        body: Stack(
          children: [
            ListenableBuilder(
              listenable: _accountRepository,
              builder: (context, _) {
                final username = _activeUsername;
                return IndexedStack(
                  index: _currentIndex,
                  children: [
                    HomeScreen(
                      username: username,
                      repository: _repository,
                      messageRepository: _messageRepository,
                      showBottomNav: false,
                      onCreateNgl: _openCreateNgl,
                      onOpenLinksTab: () => _selectTab(1),
                      onOpenProfileTab: () => _selectTab(3),
                    ),
                    LinksScreen(
                      repository: _repository,
                      messageRepository: _messageRepository,
                      onCreateNgl: _openCreateNgl,
                    ),
                    InboxScreen(
                      username: username,
                      messageRepository: _messageRepository,
                      nglRepository: _repository,
                      storyExportService: widget.storyExportService,
                    ),
                    ProfileScreen(
                      username: username,
                      accountRepository: _accountRepository,
                      preferences: widget.preferences,
                      onLogout: _handleLogout,
                    ),
                  ],
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: compositionWidth,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: ListenableBuilder(
                        listenable: _messageRepository,
                        builder: (context, _) => AppBottomNav(
                          selected: _currentIndex,
                          unreadCount: _messageRepository.unreadCount,
                          onTap: _selectTab,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private wrapper that re-instantiates LoginScreen after logout while keeping
/// the shared repository instances intact.
class _LoginWrapper extends StatelessWidget {
  final NglRepository? repository;
  final MessageRepository? messageRepository;
  final AccountRepository accountRepository;
  final SharedPreferences? preferences;
  final ImagePickerService? imagePickerService;
  final StoryExportService? storyExportService;

  const _LoginWrapper({
    this.repository,
    this.messageRepository,
    required this.accountRepository,
    this.preferences,
    this.imagePickerService,
    this.storyExportService,
  });

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      accountRepository: accountRepository,
      onLoginSuccess: (username) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            settings: const RouteSettings(name: MainShell.routeName),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) => MainShell(
              username: username.isNotEmpty ? username : 'solvera',
              repository: repository,
              messageRepository: messageRepository,
              accountRepository: accountRepository,
              preferences: preferences,
              imagePickerService: imagePickerService,
              storyExportService: storyExportService,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );
  }
}
