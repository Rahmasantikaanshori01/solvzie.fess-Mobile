import 'package:flutter/foundation.dart';
import 'package:mobile/features/profile/repository/account_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accordion sections inside Profile settings card.
enum ProfileSection { none, editProfil, ubahPassword }

/// Key for storing notification toggle in SharedPreferences.
const String kPesanBaruNotifPrefKey = 'pesanBaruNotif';

/// State controller for the Profile screen, backed by [AccountRepository] and [SharedPreferences].
class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier({
    required AccountRepository repository,
    SharedPreferences? preferences,
  })  : _repository = repository,
        _preferences = preferences {
    _repository.addListener(_onAccountChanged);
    if (_preferences != null) {
      _pesanBaruNotif = _preferences!.getBool(kPesanBaruNotifPrefKey) ?? true;
    } else {
      loadPreferences();
    }
  }

  final AccountRepository _repository;
  SharedPreferences? _preferences;
  bool _disposed = false;

  void _onAccountChanged() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.removeListener(_onAccountChanged);
    super.dispose();
  }

  AccountData get account => _repository.account;

  // ── Notification toggle ────────────────────────────────────────────────────
  bool _pesanBaruNotif = true;
  bool get pesanBaruNotif => _pesanBaruNotif;

  Future<void> loadPreferences() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    if (_disposed) return;
    _preferences = prefs;
    final stored = prefs.getBool(kPesanBaruNotifPrefKey) ?? true;
    if (_pesanBaruNotif != stored) {
      _pesanBaruNotif = stored;
      notifyListeners();
    }
  }

  Future<void> toggleNotif(bool value) async {
    _pesanBaruNotif = value;
    _toastMessage = value ? 'Notifikasi aktif' : 'Notifikasi dimatikan';
    notifyListeners();
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    if (_disposed) return;
    _preferences = prefs;
    await prefs.setBool(kPesanBaruNotifPrefKey, value);
  }

  // ── Accordion ──────────────────────────────────────────────────────────────
  ProfileSection _openSection = ProfileSection.none;
  ProfileSection get openSection => _openSection;

  void toggleSection(ProfileSection section) {
    _openSection = (_openSection == section) ? ProfileSection.none : section;
    _clearFieldErrors();
    notifyListeners();
  }

  // ── Per-field errors ───────────────────────────────────────────────────────
  String? _usernameError;
  String? get usernameError => _usernameError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _oldPasswordError;
  String? get oldPasswordError => _oldPasswordError;

  String? _newPasswordError;
  String? get newPasswordError => _newPasswordError;

  String? _confirmPasswordError;
  String? get confirmPasswordError => _confirmPasswordError;

  void clearUsernameError() {
    if (_usernameError == null) return;
    _usernameError = null;
    notifyListeners();
  }

  void clearEmailError() {
    if (_emailError == null) return;
    _emailError = null;
    notifyListeners();
  }

  void clearOldPasswordError() {
    if (_oldPasswordError == null) return;
    _oldPasswordError = null;
    notifyListeners();
  }

  void clearNewPasswordError() {
    if (_newPasswordError == null) return;
    _newPasswordError = null;
    notifyListeners();
  }

  void clearConfirmPasswordError() {
    if (_confirmPasswordError == null) return;
    _confirmPasswordError = null;
    notifyListeners();
  }

  void _clearFieldErrors() {
    _usernameError = null;
    _emailError = null;
    _oldPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;
  }

  // ── Async state & toast feedback ───────────────────────────────────────────
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _toastMessage;
  String? get toastMessage => _toastMessage;

  void clearToast() {
    _toastMessage = null;
  }

  // ── Edit profil ────────────────────────────────────────────────────────────
  Future<bool> saveProfile({
    required String username,
    required String email,
  }) async {
    if (_isSaving) return false;

    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim();

    if (trimmedUsername == account.username && trimmedEmail == account.email) {
      _clearFieldErrors();
      _toastMessage = 'Tidak ada perubahan';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _usernameError = null;
    _emailError = null;
    notifyListeners();

    try {
      String? uErr;
      String? eErr;

      if (trimmedUsername.length < 3) {
        uErr = 'Minimal 3 karakter, ya.';
      } else if (trimmedUsername.toLowerCase() !=
              account.username.toLowerCase() &&
          await _repository.isUsernameTaken(trimmedUsername)) {
        uErr = 'Username sudah dipakai';
      }

      if (!isValidAccountEmail(trimmedEmail)) {
        eErr = 'Masukkan email yang valid.';
      } else if (trimmedEmail.toLowerCase() != account.email.toLowerCase() &&
          await _repository.isEmailTaken(trimmedEmail)) {
        eErr = 'Email sudah dipakai';
      }

      if (uErr != null || eErr != null) {
        _usernameError = uErr;
        _emailError = eErr;
        return false;
      }

      await _repository.updateProfile(
        username: trimmedUsername,
        email: trimmedEmail,
      );
      _openSection = ProfileSection.none;
      _clearFieldErrors();
      _toastMessage = 'Profil diperbarui';
      return true;
    } on ArgumentError catch (e) {
      final msg = '${e.message}';
      if (msg.toLowerCase().contains('email')) {
        _emailError = msg;
      } else {
        _usernameError = msg;
      }
      return false;
    } finally {
      _isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  // ── Ubah password ──────────────────────────────────────────────────────────
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isSaving) return false;

    _isSaving = true;
    _oldPasswordError = null;
    _newPasswordError = null;
    _confirmPasswordError = null;
    notifyListeners();

    try {
      String? oldErr;
      String? newErr;
      String? confirmErr;

      final oldValid =
          oldPassword.isNotEmpty && await _repository.verifyPassword(oldPassword);
      if (!oldValid) {
        oldErr = 'Password lama salah';
      }

      if (newPassword.length < 6) {
        newErr = 'Password minimal 6 karakter.';
      } else if (oldValid && newPassword == oldPassword) {
        newErr = 'Password baru harus beda dari yang lama';
      }

      if (confirmPassword != newPassword) {
        confirmErr = 'Password belum sama.';
      }

      if (oldErr != null || newErr != null || confirmErr != null) {
        _oldPasswordError = oldErr;
        _newPasswordError = newErr;
        _confirmPasswordError = confirmErr;
        return false;
      }

      final ok = await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (!ok) {
        _oldPasswordError = 'Password lama salah';
        return false;
      }

      _openSection = ProfileSection.none;
      _clearFieldErrors();
      _toastMessage = 'Password berhasil diubah';
      return true;
    } on ArgumentError catch (e) {
      _newPasswordError = '${e.message}';
      return false;
    } finally {
      _isSaving = false;
      if (!_disposed) notifyListeners();
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    _openSection = ProfileSection.none;
    _clearFieldErrors();
    _toastMessage = null;
    await _repository.signOut();
  }
}
