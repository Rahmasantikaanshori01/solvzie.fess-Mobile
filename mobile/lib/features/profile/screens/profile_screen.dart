import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/profile/state/profile_notifier.dart';
import 'package:mobile/features/profile/widgets/logout_dialog.dart';
import 'package:mobile/features/profile/widgets/profile_card.dart';
import 'package:mobile/features/profile/widgets/profile_header.dart';
import 'package:mobile/features/profile/widgets/profile_toast.dart';
import 'package:mobile/features/profile/widgets/settings_section.dart';
import 'package:mobile/features/profile/widgets/shared_account_note.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile tab screen (tab index 3 in MainShell).
class ProfileScreen extends StatefulWidget {
  final String username;
  final AccountRepository? accountRepository;
  final SharedPreferences? preferences;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    required this.username,
    this.accountRepository,
    this.preferences,
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AccountRepository _repository;
  late final ProfileNotifier _notifier;

  @override
  void initState() {
    super.initState();
    final repo = widget.accountRepository ?? MockAccountRepository.instance;
    _repository = repo;
    if (widget.accountRepository == null && repo is MockAccountRepository) {
      repo.initFromLogin(widget.username);
    }
    _notifier = ProfileNotifier(
      repository: _repository,
      preferences: widget.preferences,
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await LogoutDialog.show(context);
    if (confirmed == true) {
      await _notifier.signOut();
      if (!mounted) return;
      widget.onLogout?.call();
    }
  }

  void _consumePendingToast() {
    final msg = _notifier.toastMessage;
    if (msg == null) return;
    _notifier.clearToast();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showProfileToast(context, msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;

    return Scaffold(
      backgroundColor: SplashColors.tealDeep,
      body: Center(
        child: SizedBox(
          width: compositionWidth,
          height: size.height,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: SplashColors.teal,
              boxShadow: screenWidth > 430.0
                  ? [
                      BoxShadow(
                        color: SplashColors.tealDeep.withValues(alpha: 0.7),
                        blurRadius: 60,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _ProfileGridPainter()),
                ),
                Positioned(
                  bottom: 100,
                  right: -8,
                  child: Transform.rotate(
                    angle: 0.14,
                    child: const SizedBox(
                      width: 56,
                      height: 34,
                      child: CustomPaint(painter: FishPainter()),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: ListenableBuilder(
                    listenable: _notifier,
                    builder: (context, _) {
                      _consumePendingToast();
                      final account = _notifier.account;
                      final displayUsername = account.username.isNotEmpty
                          ? account.username
                          : widget.username;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ProfileHeader(),
                            const SizedBox(height: 16),
                            ProfileCard(
                              username: displayUsername,
                              email: account.email,
                            ),
                            const SizedBox(height: 14),
                            const SharedAccountNote(),
                            const SizedBox(height: 14),
                            SettingsSection(notifier: _notifier),
                            const SizedBox(height: 16),
                            _LogoutOutlineButton(onTap: _handleLogout),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutOutlineButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutOutlineButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Logout',
      child: Material(
        color: SplashColors.white,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: SplashColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: SplashColors.pink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: SplashColors.buttonPinkShadow,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: SplashColors.inboxMagentaText,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.inboxMagentaText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileGridPainter extends CustomPainter {
  const _ProfileGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double cellSize = 22.0;
    final paint = Paint()
      ..color = SplashColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileGridPainter oldDelegate) => false;
}
