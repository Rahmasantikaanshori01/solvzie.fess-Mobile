import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Hashes a plaintext password using SHA-256 so passwords are never stored in plain text.
String hashAccountPassword(String plainPassword) {
  final bytes = utf8.encode(plainPassword);
  return sha256.convert(bytes).toString();
}

/// Validates email format consistently across Auth and Profile.
bool isValidAccountEmail(String email) {
  final trimmed = email.trim();
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
}

/// Data model for a user account.
class AccountData {
  final String id;
  final String username;
  final String email;
  final String passwordHash;

  const AccountData({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  AccountData copyWith({
    String? id,
    String? username,
    String? email,
    String? passwordHash,
  }) {
    return AccountData(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}

/// Abstract interface for account and session operations.
///
/// Backed by [MockAccountRepository] in development and tests;
/// will be replaced by an API-backed implementation later.
abstract class AccountRepository extends ChangeNotifier {
  /// Returns the currently active account (or a blank fallback when signed out).
  AccountData get account;

  /// Returns the active account if signed in, otherwise null.
  AccountData? get currentAccount;

  /// Whether a user session is currently active.
  bool get isSignedIn;

  /// Checks whether [username] is already used by another account.
  Future<bool> isUsernameTaken(String username);

  /// Checks whether [email] is already used by another account.
  Future<bool> isEmailTaken(String email);

  /// Updates the active account's username and email.
  Future<void> updateProfile({
    required String username,
    required String email,
  });

  /// Verifies that [plainPassword] matches the active account's stored hash.
  Future<bool> verifyPassword(String plainPassword);

  /// Changes password after verifying [oldPassword]. Returns false if wrong.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Authenticates synchronously for LoginScreen compatibility.
  /// Returns false when an existing account matches [username] and the password is wrong.
  bool signInSync({required String username, required String password});

  /// Signs the current user out (clears active session while preserving accounts).
  Future<void> signOut();
}

/// In-memory mock implementation of [AccountRepository].
class MockAccountRepository extends AccountRepository {
  MockAccountRepository._() {
    _seedDefaults();
  }

  static final MockAccountRepository instance = MockAccountRepository._();

  /// Creates an isolated repository instance for unit/widget testing.
  factory MockAccountRepository.isolated({
    String username = 'solvera',
    String email = 'solvera@solvzie.fess',
    String password = 'pass123',
  }) {
    final repo = MockAccountRepository._();
    repo._accounts[0] = AccountData(
      id: 'acc-1',
      username: username,
      email: email,
      passwordHash: hashAccountPassword(password),
    );
    return repo;
  }

  final List<AccountData> _accounts = [];
  String? _activeAccountId;

  static const AccountData _guestFallback = AccountData(
    id: '',
    username: '',
    email: '',
    passwordHash: '',
  );

  void _seedDefaults() {
    _accounts
      ..clear()
      ..addAll([
        AccountData(
          id: 'acc-1',
          username: 'solvera',
          email: 'solvera@solvzie.fess',
          passwordHash: hashAccountPassword('pass123'),
        ),
        AccountData(
          id: 'acc-2',
          username: 'naya',
          email: 'naya@solvzie.fess',
          passwordHash: hashAccountPassword('naya123'),
        ),
        AccountData(
          id: 'acc-3',
          username: 'teman',
          email: 'teman@solvzie.fess',
          passwordHash: hashAccountPassword('teman123'),
        ),
      ]);
    _activeAccountId = 'acc-1';
  }

  /// Resets accounts and session back to defaults (intended for tests).
  void resetToDefaults() {
    _seedDefaults();
    notifyListeners();
  }

  @override
  bool get isSignedIn => currentAccount != null;

  @override
  AccountData? get currentAccount {
    if (_activeAccountId == null) return null;
    for (final acc in _accounts) {
      if (acc.id == _activeAccountId) return acc;
    }
    return null;
  }

  @override
  AccountData get account => currentAccount ?? _guestFallback;

  /// Ensures a session exists for [username] when entering [MainShell] or [ProfileScreen].
  void initFromLogin(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    final lower = trimmed.toLowerCase();

    final current = currentAccount;
    if (current != null && current.username.toLowerCase() == lower) {
      return;
    }

    final idx = _accounts.indexWhere((a) => a.username.toLowerCase() == lower);
    if (idx != -1) {
      _activeAccountId = _accounts[idx].id;
    } else {
      final slug = lower.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
      final newAcc = AccountData(
        id: 'acc-${_accounts.length + 1}',
        username: trimmed,
        email: '${slug.isEmpty ? 'user' : slug}@solvzie.fess',
        passwordHash: hashAccountPassword('pass123'),
      );
      _accounts.add(newAcc);
      _activeAccountId = newAcc.id;
    }
    notifyListeners();
  }

  @override
  bool signInSync({required String username, required String password}) {
    final trimmed = username.trim();
    if (trimmed.length < 3 || password.length < 6) return false;

    final lower = trimmed.toLowerCase();
    final idx = _accounts.indexWhere((a) => a.username.toLowerCase() == lower);
    final hashed = hashAccountPassword(password);

    if (idx != -1) {
      if (_accounts[idx].passwordHash != hashed) {
        return false;
      }
      _activeAccountId = _accounts[idx].id;
      notifyListeners();
      return true;
    }

    final slug = lower.replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    final newAcc = AccountData(
      id: 'acc-${_accounts.length + 1}',
      username: trimmed,
      email: '${slug.isEmpty ? 'user' : slug}@solvzie.fess',
      passwordHash: hashed,
    );
    _accounts.add(newAcc);
    _activeAccountId = newAcc.id;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> isUsernameTaken(String username) async {
    final lower = username.trim().toLowerCase();
    final activeId = currentAccount?.id;
    return _accounts.any(
      (a) => a.id != activeId && a.username.toLowerCase() == lower,
    );
  }

  @override
  Future<bool> isEmailTaken(String email) async {
    final lower = email.trim().toLowerCase();
    final activeId = currentAccount?.id;
    return _accounts.any(
      (a) => a.id != activeId && a.email.toLowerCase() == lower,
    );
  }

  @override
  Future<void> updateProfile({
    required String username,
    required String email,
  }) async {
    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim();

    if (trimmedUsername.length < 3) {
      throw ArgumentError('Minimal 3 karakter, ya.');
    }
    if (!isValidAccountEmail(trimmedEmail)) {
      throw ArgumentError('Masukkan email yang valid.');
    }
    if (await isUsernameTaken(trimmedUsername)) {
      throw ArgumentError('Username sudah dipakai');
    }
    if (await isEmailTaken(trimmedEmail)) {
      throw ArgumentError('Email sudah dipakai');
    }

    final idx = _accounts.indexWhere((a) => a.id == _activeAccountId);
    if (idx == -1) return;

    _accounts[idx] = _accounts[idx].copyWith(
      username: trimmedUsername,
      email: trimmedEmail,
    );
    notifyListeners();
  }

  @override
  Future<bool> verifyPassword(String plainPassword) async {
    final active = currentAccount;
    if (active == null) return false;
    return hashAccountPassword(plainPassword) == active.passwordHash;
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final active = currentAccount;
    if (active == null) return false;
    if (!await verifyPassword(oldPassword)) return false;
    if (newPassword.length < 6) {
      throw ArgumentError('Password minimal 6 karakter.');
    }
    final newHash = hashAccountPassword(newPassword);
    if (newHash == active.passwordHash) {
      throw ArgumentError('Password baru harus beda dari yang lama');
    }

    final idx = _accounts.indexWhere((a) => a.id == active.id);
    if (idx == -1) return false;

    _accounts[idx] = _accounts[idx].copyWith(passwordHash: newHash);
    notifyListeners();
    return true;
  }

  @override
  Future<void> signOut() async {
    _activeAccountId = null;
    notifyListeners();
  }
}
