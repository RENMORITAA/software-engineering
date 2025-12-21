import 'package:flutter/material.dart';

/// ユーザーロールの列挙型
enum UserRole {
  requester, // 依頼者（c_）
  deliverer, // 配達員（d_）
  store,     // 店舗（s_）
  admin,     // 管理者
}

/// ユーザーロール管理のためのProvider
/// 設計書に基づき、ロール判定とUIテーマ管理を行う
class UserRoleProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.requester;
  int? _userId;
  String? _userEmail;
  bool _isLoggedIn = false;

  // ゲッター
  UserRole get currentRole => _currentRole;
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  /// ロールのプレフィックスを取得
  String get rolePrefix {
    switch (_currentRole) {
      case UserRole.requester:
        return 'c_';
      case UserRole.deliverer:
        return 'd_';
      case UserRole.store:
        return 's_';
      case UserRole.admin:
        return 'admin_';
    }
  }

  /// ロールに応じたテーマカラーを取得
  Color get themeColor {
    switch (_currentRole) {
      case UserRole.requester:
        return const Color(0xFF1A237E); // 依頼者: 濃い青
      case UserRole.deliverer:
        return const Color(0xFF2E7D32); // 配達員: 緑
      case UserRole.store:
        return const Color(0xFFE65100); // 店舗: オレンジ
      case UserRole.admin:
        return const Color(0xFF424242); // 管理者: グレー
    }
  }

  /// ロールに応じたアクセントカラーを取得
  Color get accentColor {
    switch (_currentRole) {
      case UserRole.requester:
        return const Color(0xFFFFD600); // 黄色
      case UserRole.deliverer:
        return const Color(0xFFA5D6A7); // 薄緑
      case UserRole.store:
        return const Color(0xFFFFCC80); // 薄オレンジ
      case UserRole.admin:
        return const Color(0xFFBDBDBD); // 薄グレー
    }
  }

  /// ロール名（日本語）を取得
  String get roleDisplayName {
    switch (_currentRole) {
      case UserRole.requester:
        return '依頼者';
      case UserRole.deliverer:
        return '配達員';
      case UserRole.store:
        return '店舗';
      case UserRole.admin:
        return '管理者';
    }
  }

  /// ログイン処理
  void login({
    required int userId,
    required String email,
    required String role,
  }) {
    _userId = userId;
    _userEmail = email;
    _currentRole = _parseRole(role);
    _isLoggedIn = true;
    notifyListeners();
  }

  /// ログアウト処理
  void logout() {
    _userId = null;
    _userEmail = null;
    _currentRole = UserRole.requester;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// ロールを変更
  void changeRole(UserRole newRole) {
    if (_currentRole != newRole) {
      _currentRole = newRole;
      notifyListeners();
    }
  }

  /// 文字列からロールをパース
  UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'requester':
        return UserRole.requester;
      case 'deliverer':
        return UserRole.deliverer;
      case 'store':
        return UserRole.store;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.requester;
    }
  }

  /// ロールを文字列として取得
  String roleToString() {
    switch (_currentRole) {
      case UserRole.requester:
        return 'requester';
      case UserRole.deliverer:
        return 'deliverer';
      case UserRole.store:
        return 'store';
      case UserRole.admin:
        return 'admin';
    }
  }

  /// 特定のロールかどうかを判定
  bool isRequester() => _currentRole == UserRole.requester;
  bool isDeliverer() => _currentRole == UserRole.deliverer;
  bool isStore() => _currentRole == UserRole.store;
  bool isAdmin() => _currentRole == UserRole.admin;
}
