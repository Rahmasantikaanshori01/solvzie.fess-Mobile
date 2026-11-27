import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/auth/screens/lupa_password_screen.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/splash/widgets/burst_painter.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';
import 'register_screen.dart';

/// LoginScreen for solvzie.fess
///
/// Implemented directly from the Figma Make reference design:
/// - Screen container: 22px grid on #155E75 (teal) background, max-width 430px centered.
/// - Background floating decos: Fish rotated -12° and StickerStar rotated +7°.
/// - Hero section: Standard Logo (solvzie.fess with speech bubble) + "HALO!" 3D title with
///   "WELCOME BACK" slant pill and ✦ spark + subtitle "Ada pesan rahasia menunggumu.".
/// - Auth card: White card with 3px #D946EF border, 28px radius, and 0 8px 0 shadow.
/// - Form: Username field, Password field with toggle visibility, "Tetap masuk" checkbox,
///   "Masuk" primary gradient button, and "Belum punya akun? Daftar" switch.
/// - Footer note: "100% anonim, 100% kamu." in Space Mono #A7F3D0.
class LoginScreen extends StatefulWidget {
  /// Called when login succeeds, with the entered username.
  final void Function(String username)? onLoginSuccess;
  final VoidCallback? onNavigateToRegister;
  final AccountRepository? accountRepository;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onNavigateToRegister,
    this.accountRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  bool _submitted = false;
  bool _isButtonPressed = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submitLogin() {
    setState(() {
      _submitted = true;
      _authError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final bool isUsernameValid = username.length >= 3;
    final bool isPasswordValid = password.length >= 6;

    if (!isUsernameValid || !isPasswordValid) {
      return;
    }

    final repo = widget.accountRepository ?? MockAccountRepository.instance;
    if (!repo.signInSync(username: username, password: password)) {
      setState(() {
        _authError = 'Username atau password salah.';
      });
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!(username);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SplashColors.tealDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: SplashColors.mint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Halo, $username! Kamu berhasil masuk.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onRegisterTap() {
    if (widget.onNavigateToRegister != null) {
      widget.onNavigateToRegister!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Responsive tablet/desktop constraint matching Figma Make .app-shell (max 430px)
    final double compositionWidth = screenWidth > 430.0 ? 430.0 : screenWidth;
    final bool isSmallHeight = screenHeight < 700;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final String? usernameError = _submitted && username.length < 3
        ? 'Minimal 3 karakter, ya.'
        : null;

    final String? passwordError = _submitted && password.length < 6
        ? 'Password minimal 6 karakter.'
        : _authError;

    return Scaffold(
      backgroundColor: const Color(0xFF0E4659), // outer desktop/tablet background
      body: Center(
        child: SizedBox(
          width: compositionWidth,
          height: screenHeight,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: SplashColors.teal,
              boxShadow: screenWidth > 430.0
                  ? [
                      BoxShadow(
                        color: const Color(0xFF082D3D).withValues(alpha: 0.60),
                        blurRadius: 60,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // 1. 22px Grid background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _AuthGridPainter(),
                  ),
                ),

                // 2. Floating deco: Fish (top: 90, right: -16, rotate -12°)
                Positioned(
                  top: isSmallHeight ? 50 : 90,
                  right: -16,
                  child: const _FishDeco(),
                ),

                // 3. Floating deco: Star (top: 135, left: -18, rotate 7°)
                Positioned(
                  top: isSmallHeight ? 95 : 135,
                  left: -18,
                  child: const _StarDeco(size: 54),
                ),

                // 4. Scrollable foreground content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: isSmallHeight ? 16.0 : 34.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Hero Section ─────────────────────────────────────
                        SizedBox(height: isSmallHeight ? 6.0 : 16.0),

                        // Logo: solvzie.fess
                        const _AuthLogo(),

                        SizedBox(height: isSmallHeight ? 9.0 : 24.0),

                        // Title: "HALO!" + "WELCOME BACK" slant pill + ✦ spark
                        _PageTitle(isSmallHeight: isSmallHeight),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.only(top: 9.0),
                          child: Text(
                            'Ada pesan rahasia menunggumu.',
                            style: TextStyle(
                              fontFamily: SplashTypography.fontInter,
                              fontFamilyFallback: SplashTypography.fontFallbackSans,
                              fontSize: 13.0,
                              color: Colors.white.withValues(alpha: 0.90),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: isSmallHeight ? 14.0 : 22.0),

                        // ── Auth Card ────────────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28.0),
                            border: Border.all(
                              color: SplashColors.magenta,
                              width: 3.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 8),
                                color: Color(0x73501B64), // rgba(80, 27, 100, 0.45)
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isSmallHeight ? 18.0 : 22.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username Field
                              _AuthField(
                                label: 'Username',
                                placeholder: 'username kamu',
                                controller: _usernameController,
                                focusNode: _usernameFocus,
                                error: usernameError,
                                isSmallHeight: isSmallHeight,
                                onChanged: (val) {
                                  if (_submitted || _authError != null) {
                                    setState(() => _authError = null);
                                  }
                                },
                              ),

                              SizedBox(height: isSmallHeight ? 11.0 : 15.0),

                              // Password Field
                              _AuthField(
                                label: 'Password',
                                placeholder: 'minimal 6 karakter',
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                error: passwordError,
                                isSmallHeight: isSmallHeight,
                                obscureText: !_isPasswordVisible,
                                onChanged: (val) {
                                  if (_submitted || _authError != null) {
                                    setState(() => _authError = null);
                                  }
                                },
                                rightAction: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: const Color(0xFF694F84),
                                    ),
                                  ),
                                ),
                              ),

                              // Lupa password? link
                              Align(
                                alignment: Alignment.centerRight,
                                child: Semantics(
                                  button: true,
                                  label: 'Lupa password?',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LupaPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          top: 6.0, bottom: 2.0),
                                      child: Text(
                                        'Lupa password?',
                                        style: TextStyle(
                                          fontFamily:
                                              SplashTypography.fontInter,
                                          fontFamilyFallback:
                                              SplashTypography.fontFallbackSans,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                          color: SplashColors.purple,
                                          decoration: TextDecoration.underline,
                                          decorationColor: SplashColors.purple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallHeight ? 11.0 : 15.0),

                              // Checkbox: Tetap masuk
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? SplashColors.purple
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.0),
                                        border: Border.all(
                                          color: SplashColors.purple,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Tetap masuk',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontInter,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 12.0,
                                        color: Color(0xFF4F475D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isSmallHeight ? 14.0 : 18.0),

                              // Button "Masuk"
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _isButtonPressed = true),
                                onTapUp: (_) =>
                                    setState(() => _isButtonPressed = false),
                                onTapCancel: () =>
                                    setState(() => _isButtonPressed = false),
                                onTap: _submitLogin,
                                child: Transform.translate(
                                  offset: Offset(0, _isButtonPressed ? 2 : 0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFA855F7),
                                          Color(0xFF60A5FA),
                                        ],
                                        begin: Alignment(-0.8, -0.6),
                                        end: Alignment(0.8, 0.6),
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(
                                              0, _isButtonPressed ? 2 : 4),
                                          color: const Color(0xFF683EA9),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontFredoka,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallHeight ? 11.0 : 14.0),

                              // Switch: Belum punya akun? Daftar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Belum punya akun? ',
                                    style: TextStyle(
                                      fontFamily: SplashTypography.fontInter,
                                      fontFamilyFallback:
                                          SplashTypography.fontFallbackSans,
                                      fontSize: 12.0,
                                      color: Color(0xFF70687D),
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _onRegisterTap,
                                    child: const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontFamily: SplashTypography.fontInter,
                                        fontFamilyFallback:
                                            SplashTypography.fontFallbackSans,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFA855F7),
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFFA855F7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Footer Note ──────────────────────────────────────
                        const SizedBox(height: 18.0),
                        const Text(
                          '100% anonim, 100% kamu.',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontSpaceMono,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackMono,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFA7F3D0),
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isSmallHeight ? 16.0 : 24.0),
                      ],
                    ),
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

// ── Private Sub-Widgets ──────────────────────────────────────────────────────

/// 22px x 22px grid painter on top of #155E75 (matching Figma CSS background-size: 22px 22px)
class _AuthGridPainter extends CustomPainter {
  const _AuthGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const double step = 22.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuthGridPainter oldDelegate) => false;
}

/// Floating deco: Orange fish rotated -12° (matching Figma CSS .fish-deco)
class _FishDeco extends StatelessWidget {
  const _FishDeco();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -12.0 * math.pi / 180.0,
      child: const FishWidget(
        width: 72,
        height: 42,
      ),
    );
  }
}

/// Floating deco: Magenta sticker star with white drop-shadow, rotated 7° (matching Figma CSS .star-deco)
class _StarDeco extends StatelessWidget {
  final double size;

  const _StarDeco({this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 7.0 * math.pi / 180.0,
      child: SizedBox(
        width: size,
        height: size + 3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // White drop shadow underlay (filter: drop-shadow(0 3px 0 #fff))
            Transform.translate(
              offset: const Offset(0, 3),
              child: CustomPaint(
                size: Size(size, size),
                painter: const BurstPainter(fillColor: Colors.white),
              ),
            ),
            // Magenta star body
            CustomPaint(
              size: Size(size, size),
              painter: const BurstPainter(fillColor: SplashColors.magenta),
            ),
            // Label ✦
            const Text(
              '✦',
              style: TextStyle(
                fontFamily: SplashTypography.fontFredoka,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard Logo widget: mint speech bubble with 3 dots and tail + "solvzie.fess"
class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    const double baseFontSize = 25.0;
    const double bubbleWidth = 29.0;
    const double bubbleHeight = 23.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Speech bubble icon
        SizedBox(
          width: bubbleWidth,
          height: bubbleHeight + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bubble body
              Container(
                width: bubbleWidth,
                height: bubbleHeight,
                decoration: BoxDecoration(
                  color: SplashColors.mint,
                  borderRadius: BorderRadius.circular(9.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40155E75), // rgba(21, 94, 117, 0.25)
                      offset: Offset(-3, -3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 4.0,
                        height: 4.0,
                        decoration: const BoxDecoration(
                          color: SplashColors.ink,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bubble tail at bottom left
              Positioned(
                bottom: 0,
                left: 6.0,
                child: CustomPaint(
                  size: const Size(6.0, 5.0),
                  painter: _BubbleTailPainter(color: SplashColors.mint),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        // Logo text: solvzie
        const Text(
          'solvzie',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.8,
            height: 1.0,
          ),
        ),
        // Dot: .
        const Text(
          '.',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontSize: 32.0,
            fontWeight: FontWeight.w700,
            color: SplashColors.pink,
            letterSpacing: -0.8,
            height: 1.0,
          ),
        ),
        // Logo text: fess
        const Text(
          'fess',
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontSize: baseFontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.8,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;

  const _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// PageTitle widget: "HALO!" with 3D text-shadow + "WELCOME BACK" slant pill + ✦ spark
class _PageTitle extends StatelessWidget {
  final bool isSmallHeight;

  const _PageTitle({required this.isSmallHeight});

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = isSmallHeight ? 45.0 : 54.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -1.0 * math.pi / 180.0,
              child: Text(
                'HALO!',
                style: TextStyle(
                  fontFamily: SplashTypography.fontFredoka,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: SplashColors.mint,
                  letterSpacing: -2.0,
                  height: 0.9,
                  shadows: const [
                    Shadow(offset: Offset(0, 5), color: Color(0xFF188C72)),
                    Shadow(offset: Offset(0, 9), color: Color(0x521E1B3A)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Transform.rotate(
              angle: -5.0 * math.pi / 180.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13.0, vertical: 6.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A3D), Color(0xFFFF6EC7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(0, 3),
                      color: Color(0xFFA23A92),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -6,
          right: -16,
          child: Transform.rotate(
            angle: 20.0 * math.pi / 180.0,
            child: const Text(
              '✦',
              style: TextStyle(
                color: Color(0xFFFFD25A),
                fontSize: 20,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable input field matching .field and .field-box in Figma Make
class _AuthField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? error;
  final bool isSmallHeight;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? rightAction;

  const _AuthField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    this.error,
    this.isSmallHeight = false,
    this.obscureText = false,
    this.onChanged,
    this.rightAction,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = error != null;
    final bool isFocused = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: SplashTypography.fontInter,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1B3A),
          ),
        ),
        const SizedBox(height: 7.0),
        Container(
          height: isSmallHeight ? 40.0 : 47.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFE8465C)
                  : isFocused
                      ? SplashColors.teal
                      : const Color(0xFFB65BE7),
              width: 2.0,
            ),
            boxShadow: isFocused && !hasError
                ? const [
                    BoxShadow(
                      color: Color(0x595EEAA8), // rgba(94, 234, 168, 0.35)
                      spreadRadius: 3.0,
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  style: const TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 14.0,
                    color: Color(0xFF1E1B3A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: SplashTypography.fontInter,
                      fontFamilyFallback: SplashTypography.fontFallbackSans,
                      fontSize: 14.0,
                      color: Color(0xFF908CA4),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (rightAction != null) rightAction!,
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5.0),
          Text(
            error!,
            style: const TextStyle(
              fontFamily: SplashTypography.fontInter,
              fontFamilyFallback: SplashTypography.fontFallbackSans,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD33154),
            ),
          ),
        ],
      ],
    );
  }
}
