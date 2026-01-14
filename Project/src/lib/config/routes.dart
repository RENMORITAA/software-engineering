import 'package:flutter/material.dart';

import '../page/login_page.dart';
import '../page/new_member.dart';
import '../page/requester/c_root_page.dart';
import '../page/deliverer/d_root_page.dart';
import '../page/store/s_root_page.dart';
import '../utils/auth_guard.dart';

class AppRoutes {
  // 認証
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';

  // 依頼側（ユーザー）
  static const String requestorHome = '/requester/home';
  static const String requestorProducts = '/requester/products';
  static const String requestorCart = '/requester/cart';
  static const String requestorOrders = '/requester/orders';
  static const String requestorProfile = '/requester/profile';

  // 配達側
  static const String delivererHome = '/deliverer/home';
  static const String delivererJobs = '/deliverer/jobs';
  static const String delivererMap = '/deliverer/map';
  static const String delivererHistory = '/deliverer/history';
  static const String delivererProfile = '/deliverer/profile';

  // 店舗側
  static const String storeHome = '/store/home';
  static const String storeOrders = '/store/orders';
  static const String storeProducts = '/store/products';
  static const String storeProfile = '/store/profile';

  /// 依頼側タブのルート一覧
  static const List<String> requesterRoutes = [
    requestorHome,
    requestorProducts,
    requestorCart,
    requestorOrders,
    requestorProfile,
  ];

  /// 配達側タブのルート一覧
  static const List<String> delivererRoutes = [
    delivererHome,
    delivererJobs,
    delivererMap,
    delivererHistory,
    delivererProfile,
  ];

  /// 店舗側タブのルート一覧
  static const List<String> storeRoutes = [
    storeHome,
    storeOrders,
    storeProducts,
    storeProfile,
  ];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final path = settings.name ?? '/';
    
    // ルート（/） - RootGuardで認証状態を確認
    if (path == root) {
      return MaterialPageRoute(
        builder: (_) => const RootGuard(),
        settings: settings,
      );
    }
    
    // ログイン - GuestGuardで既にログイン済みならホームへ
    if (path == login) {
      return MaterialPageRoute(
        builder: (_) => const GuestGuard(child: LoginPage()),
        settings: settings,
      );
    }
    
    // 新規登録 - GuestGuardで既にログイン済みならホームへ
    if (path == register) {
      return MaterialPageRoute(
        builder: (_) => const GuestGuard(child: NewMemberPage()),
        settings: settings,
      );
    }
    
    // 依頼側のルート - AuthGuardで認証チェック
    if (path.startsWith('/requester')) {
      final index = requesterRoutes.indexOf(path);
      return MaterialPageRoute(
        builder: (_) => AuthGuard(
          allowedRoles: const ['requester'],
          child: CRootPage(initialIndex: index >= 0 ? index : 0),
        ),
        settings: settings,
      );
    }
    
    // 配達側のルート - AuthGuardで認証チェック
    if (path.startsWith('/deliverer')) {
      final index = delivererRoutes.indexOf(path);
      return MaterialPageRoute(
        builder: (_) => AuthGuard(
          allowedRoles: const ['deliverer'],
          child: DRootPage(initialIndex: index >= 0 ? index : 0),
        ),
        settings: settings,
      );
    }
    
    // 店舗側のルート - AuthGuardで認証チェック
    if (path.startsWith('/store')) {
      final index = storeRoutes.indexOf(path);
      return MaterialPageRoute(
        builder: (_) => AuthGuard(
          allowedRoles: const ['store'],
          child: SRootPage(initialIndex: index >= 0 ? index : 0),
        ),
        settings: settings,
      );
    }

    // 不明なルートはルート（/）へ
    return MaterialPageRoute(
      builder: (_) => const RootGuard(),
      settings: settings,
    );
  }

  /// ルート名からタブインデックスを取得
  static int getTabIndex(String route) {
    if (requesterRoutes.contains(route)) {
      return requesterRoutes.indexOf(route);
    }
    if (delivererRoutes.contains(route)) {
      return delivererRoutes.indexOf(route);
    }
    if (storeRoutes.contains(route)) {
      return storeRoutes.indexOf(route);
    }
    return 0;
  }
}
