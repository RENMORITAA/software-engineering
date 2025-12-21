import 'package:flutter/material.dart';

import '../page/login_page.dart';
import '../page/new_member.dart';
import '../page/requester/c_root_page.dart';
import '../page/deliverer/d_root_page.dart';
import '../page/store/s_root_page.dart';

class AppRoutes {
  // 認証
  static const String login = '/';
  static const String register = '/register';

  // 依頼側（ユーザー）
  static const String requestorHome = '/requester/home';

  // 配達側
  static const String delivererHome = '/deliverer/home';

  // 店舗側
  static const String storeHome = '/store/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const NewMemberPage());
      
      // 依頼側
      case requestorHome:
        return MaterialPageRoute(builder: (_) => const CRootPage());
      
      // 配達側
      case delivererHome:
        return MaterialPageRoute(builder: (_) => const DRootPage());
      
      // 店舗側
      case storeHome:
        return MaterialPageRoute(builder: (_) => const SRootPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
