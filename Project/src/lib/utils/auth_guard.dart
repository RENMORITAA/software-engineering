import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';

/// 認証ガードウィジェット
/// 認証が必要なページをラップし、未認証の場合はログインページへリダイレクト
class AuthGuard extends StatefulWidget {
  final Widget child;
  final List<String>? allowedRoles;

  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (!isLoggedIn) {
        _redirectToLogin();
        return;
      }

      // ロールチェック
      if (widget.allowedRoles != null && widget.allowedRoles!.isNotEmpty) {
        final role = await _authService.getSavedRole();
        // ロール情報がない、またはロールが許可されていない場合
        if (role == null) {
          debugPrint('[AuthGuard] No saved role found, logging out');
          await _authService.logout();
          _redirectToLogin();
          return;
        }
        
        if (!widget.allowedRoles!.contains(role)) {
          debugPrint('[AuthGuard] Role not allowed: $role, required: ${widget.allowedRoles}');
          _redirectToLogin();
          return;
        }
      }

      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('[AuthGuard] Auth check error: $e');
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}

/// 認証済みユーザーがログインページにアクセスした場合のガード
/// ホームページへリダイレクト
class GuestGuard extends StatefulWidget {
  final Widget child;

  const GuestGuard({
    super.key,
    required this.child,
  });

  @override
  State<GuestGuard> createState() => _GuestGuardState();
}

class _GuestGuardState extends State<GuestGuard> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;
  bool _shouldShowPage = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        // すでにログイン済みならホームへリダイレクト
        final role = await _authService.getSavedRole();
        if (role != null) {
          _redirectToHome(role);
          return;
        }
        // ロール情報がない場合はログアウト状態として扱う
        await _authService.logout();
      }

      if (mounted) {
        setState(() {
          _shouldShowPage = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('[GuestGuard] Auth check error: $e');
      if (mounted) {
        setState(() {
          _shouldShowPage = true;
          _isChecking = false;
        });
      }
    }
  }

  void _redirectToHome(String role) {
    if (!mounted) return;
    
    String route;
    switch (role) {
      case 'requester':
        route = AppRoutes.requestorHome;
        break;
      case 'deliverer':
        route = AppRoutes.delivererHome;
        break;
      case 'store':
        route = AppRoutes.storeHome;
        break;
      default:
        route = AppRoutes.requestorHome;
    }
    
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_shouldShowPage) {
      return const SizedBox.shrink();
    }

    return widget.child;
  }
}
/// ルート（/）パスのガード
/// ログイン状態に基づいて適切なページへリダイレクト
class RootGuard extends StatefulWidget {
  const RootGuard({super.key});

  @override
  State<RootGuard> createState() => _RootGuardState();
}

class _RootGuardState extends State<RootGuard> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (!mounted) return;

      if (isLoggedIn) {
        // すでにログイン済みならロールに応じたホームへ
        final role = await _authService.getSavedRole();
        if (role != null) {
          _redirectToHome(role);
          return;
        }
        // ロール情報がない場合はログアウト
        await _authService.logout();
      }

      // ログインしていなければログイン画面へ
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('[RootGuard] Auth check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _redirectToHome(String role) {
    if (!mounted) return;
    
    String route;
    switch (role) {
      case 'requester':
        route = '/requester/home';
        break;
      case 'deliverer':
        route = '/deliverer/home';
        break;
      case 'store':
        route = '/store/home';
        break;
      default:
        route = '/requester/home';
    }
    
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}