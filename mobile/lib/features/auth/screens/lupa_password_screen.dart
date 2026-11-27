import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/profile/widgets/profile_gradient_button.dart';
import 'package:mobile/features/profile/widgets/profile_input_field.dart';
import 'package:mobile/features/splash/widgets/burst_painter.dart';
import 'package:mobile/features/splash/widgets/fish_painter.dart';

/// Forgot password screen ("LUPA PASSWORD") accessible from LoginScreen.
///
/// Validates email and displays the same generic confirmation state for any valid email
/// after a short simulated delay (preventing account enumeration).
class LupaPasswordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Duration simulatedDelay;

  const LupaPasswordScreen({
    super.key,
    this.onBack,
    this.simulatedDelay = const Duration(milliseconds: 600),
  });

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _emailFocus.removeListener(_onFocusChanged);
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    if (!isValidAccountEmail(email)) {
      setState(() => _errorMsg = 'Masukkan email yang valid.');
      return;
    }

    setState(() {
      _errorMsg = null;
      _isLoading = true;
    });

    await Future<void>.delayed(widget.simulatedDelay);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
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
                  child: CustomPaint(painter: _ForgotGridPainter()),
                ),
                Positioned(
                  top: 72,
                  right: -18,
                  child: Transform.rotate(
                    angle: -12.0 * math.pi / 180.0,
                    child: const FishWidget(width: 72, height: 42),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -16,
                  child: Transform.rotate(
                    angle: 7.0 * math.pi / 180.0,
                    child: const StickerStarWidget(label: '✦', size: 54),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular back button
                        Semantics(
                          button: true,
                          label: 'Kembali',
                          child: InkWell(
                            onTap: _handleBack,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    SplashColors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: SplashColors.white
                                      .withValues(alpha: 0.65),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: SplashColors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Transform.rotate(
                            angle: -0.017,
                            child: const Text(
                              'LUPA PASSWORD?',
                              style: TextStyle(
                                fontFamily: SplashTypography.fontLilitaOne,
                                fontFamilyFallback:
                                    SplashTypography.fontFallbackDisplay,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: SplashColors.mint,
                                height: 1.0,
                                letterSpacing: -1.0,
                                shadows: [
                                  Shadow(
                                    color: SplashColors.mintShadowDeep,
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                  Shadow(
                                    color: SplashColors.inboxCardDropShadow,
                                    offset: Offset(0, 7),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Masukkan email akunmu, nanti kami kirim link untuk membuat password baru.',
                          style: TextStyle(
                            fontFamily: SplashTypography.fontInter,
                            fontFamilyFallback:
                                SplashTypography.fontFallbackSans,
                            fontSize: 13.5,
                            color: SplashColors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: SplashColors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: SplashColors.magenta,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: SplashColors.cardShadow,
                                offset: Offset(0, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: _isSuccess
                              ? _SuccessState(onBack: _handleBack)
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ProfileInputField(
                                      label: 'Email',
                                      placeholder: 'nama@email.com',
                                      controller: _emailCtrl,
                                      focusNode: _emailFocus,
                                      error: _errorMsg,
                                      isValid: _errorMsg == null &&
                                          isValidAccountEmail(_emailCtrl.text),
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      onChanged: (_) {
                                        if (_errorMsg != null) {
                                          setState(() => _errorMsg = null);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    ProfileGradientButton(
                                      label: 'Kirim link reset',
                                      isLoading: _isLoading,
                                      onPressed: _submit,
                                    ),
                                  ],
                                ),
                        ),
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

class _SuccessState extends StatelessWidget {
  final VoidCallback onBack;

  const _SuccessState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: SplashColors.lavenderCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SplashColors.magenta, width: 2),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: SplashColors.purple,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cek emailmu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: SplashTypography.fontFredoka,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: SplashColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kalau email ini terdaftar, kami kirim link reset ke kotak masukmu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: SplashTypography.fontInter,
            fontFamilyFallback: SplashTypography.fontFallbackSans,
            fontSize: 13,
            color: SplashColors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          button: true,
          label: 'Kembali ke login',
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SplashColors.purple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Kembali ke login',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.purpleDark,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgotGridPainter extends CustomPainter {
  const _ForgotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 22.0;
    final linePaint = Paint()
      ..color = SplashColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForgotGridPainter oldDelegate) => false;
}
