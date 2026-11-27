import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/typography.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:mobile/features/profile/state/profile_notifier.dart';
import 'package:mobile/features/profile/widgets/expandable_section.dart';
import 'package:mobile/features/profile/widgets/password_field.dart';
import 'package:mobile/features/profile/widgets/profile_gradient_button.dart';
import 'package:mobile/features/profile/widgets/profile_input_field.dart';
import 'package:mobile/features/profile/widgets/shared_account_note.dart';

/// Settings white card with stacked sections:
/// 1. Edit profil (accordion)
/// 2. Ubah password (accordion)
/// 3. Notifikasi toggle
class SettingsSection extends StatefulWidget {
  final ProfileNotifier notifier;

  const SettingsSection({super.key, required this.notifier});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  // ── Edit profil controllers ────────────────────────────────────────────────
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  // ── Ubah password controllers ──────────────────────────────────────────────
  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final FocusNode _oldPassFocus = FocusNode();
  final FocusNode _newPassFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();
  int _passwordResetTick = 0;

  @override
  void initState() {
    super.initState();
    _usernameCtrl =
        TextEditingController(text: widget.notifier.account.username);
    _emailCtrl = TextEditingController(text: widget.notifier.account.email);

    for (final node in [
      _usernameFocus,
      _emailFocus,
      _oldPassFocus,
      _newPassFocus,
      _confirmPassFocus,
    ]) {
      node.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final node in [
      _usernameFocus,
      _emailFocus,
      _oldPassFocus,
      _newPassFocus,
      _confirmPassFocus,
    ]) {
      node
        ..removeListener(_onFocusChanged)
        ..dispose();
    }
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _syncEditControllersFromAccount() {
    _usernameCtrl.text = widget.notifier.account.username;
    _emailCtrl.text = widget.notifier.account.email;
  }

  void _clearPasswordFields() {
    _oldPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    setState(() => _passwordResetTick++);
  }

  Future<void> _submitProfile() async {
    FocusScope.of(context).unfocus();
    await widget.notifier.saveProfile(
      username: _usernameCtrl.text,
      email: _emailCtrl.text,
    );
  }

  Future<void> _submitPassword() async {
    FocusScope.of(context).unfocus();
    final ok = await widget.notifier.changePassword(
      oldPassword: _oldPassCtrl.text,
      newPassword: _newPassCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
    );
    if (ok && mounted) {
      _clearPasswordFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final notifier = widget.notifier;
        final open = notifier.openSection;

        return Container(
          decoration: BoxDecoration(
            color: SplashColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SplashColors.magenta, width: 3),
            boxShadow: const [
              BoxShadow(
                color: SplashColors.cardShadow,
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpandableSection(
                icon: Icons.person_outline_rounded,
                title: 'Edit profil',
                isOpen: open == ProfileSection.editProfil,
                onTap: () {
                  if (open != ProfileSection.editProfil) {
                    _syncEditControllersFromAccount();
                  }
                  notifier.toggleSection(ProfileSection.editProfil);
                },
                showDivider: true,
                child: _buildEditProfilBody(notifier),
              ),
              ExpandableSection(
                icon: Icons.edit_outlined,
                title: 'Ubah password',
                isOpen: open == ProfileSection.ubahPassword,
                onTap: () =>
                    notifier.toggleSection(ProfileSection.ubahPassword),
                showDivider: true,
                child: _buildUbahPasswordBody(notifier),
              ),
              _NotifRow(notifier: notifier),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditProfilBody(ProfileNotifier notifier) {
    final bool usernameValid = _usernameCtrl.text.trim().length >= 3 &&
        notifier.usernameError == null;
    final bool emailValid = isValidAccountEmail(_emailCtrl.text.trim()) &&
        notifier.emailError == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileInputField(
            label: 'Username',
            placeholder: 'username kamu',
            controller: _usernameCtrl,
            focusNode: _usernameFocus,
            error: notifier.usernameError,
            isValid: usernameValid,
            onChanged: (_) {
              notifier.clearUsernameError();
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          ProfileInputField(
            label: 'Email',
            placeholder: 'nama@email.com',
            controller: _emailCtrl,
            focusNode: _emailFocus,
            error: notifier.emailError,
            isValid: emailValid,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              notifier.clearEmailError();
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          ProfileGradientButton(
            label: 'Simpan perubahan',
            isLoading: notifier.isSaving,
            onPressed: _submitProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildUbahPasswordBody(ProfileNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SharedAccountNote.passwordHint(),
          const SizedBox(height: 12),
          PasswordField(
            label: 'Password lama',
            placeholder: 'masukkan password lama',
            controller: _oldPassCtrl,
            focusNode: _oldPassFocus,
            error: notifier.oldPasswordError,
            visibilityResetTick: _passwordResetTick,
            onChanged: (_) {
              notifier.clearOldPasswordError();
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          PasswordField(
            label: 'Password baru',
            placeholder: 'minimal 6 karakter',
            controller: _newPassCtrl,
            focusNode: _newPassFocus,
            error: notifier.newPasswordError,
            isValid: _newPassCtrl.text.length >= 6 &&
                notifier.newPasswordError == null,
            visibilityResetTick: _passwordResetTick,
            onChanged: (_) {
              notifier.clearNewPasswordError();
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          PasswordField(
            label: 'Konfirmasi password baru',
            placeholder: 'ulangi password baru',
            controller: _confirmPassCtrl,
            focusNode: _confirmPassFocus,
            error: notifier.confirmPasswordError,
            isValid: _confirmPassCtrl.text.isNotEmpty &&
                _confirmPassCtrl.text == _newPassCtrl.text &&
                notifier.confirmPasswordError == null,
            visibilityResetTick: _passwordResetTick,
            onChanged: (_) {
              notifier.clearConfirmPasswordError();
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          ProfileGradientButton(
            label: 'Simpan password',
            isLoading: notifier.isSaving,
            onPressed: _submitPassword,
          ),
        ],
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final ProfileNotifier notifier;

  const _NotifRow({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final bool enabled = notifier.pesanBaruNotif;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontFredoka,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SplashColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kabar saat pesan baru masuk',
                  style: TextStyle(
                    fontFamily: SplashTypography.fontInter,
                    fontFamilyFallback: SplashTypography.fontFallbackSans,
                    fontSize: 11.5,
                    color: SplashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            toggled: enabled,
            label: 'Notifikasi pesan baru',
            child: GestureDetector(
              onTap: () => notifier.toggleNotif(!enabled),
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 28,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: enabled
                          ? SplashColors.mint
                          : SplashColors.switchTrackInactive,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 180),
                      alignment: enabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: SplashColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
