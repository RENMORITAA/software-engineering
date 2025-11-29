import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/requestor/requestor_home.dart';
import '../screens/requestor/product_list_screen.dart';
import '../screens/requestor/cart_screen.dart';
import '../screens/deliverer/deliverer_home.dart';
import '../screens/deliverer/job_search_screen.dart';
import '../screens/store/store_home.dart';
import '../screens/store/menu_management_screen.dart';
import '../screens/store/order_management_screen.dart';

class AppRoutes {
  // 認証
  static const String login = '/';
  static const String register = '/register';

  // 依頼側（ユーザー）
  static const String requestorHome = '/requestor/home';
  static const String productList = '/requestor/products'; // 商品検索・一覧
  static const String cart = '/requestor/cart'; // カート

  // 配達側
  static const String delivererHome = '/deliverer/home';
  static const String jobSearch = '/deliverer/jobs'; // 求人検索

  // 店舗側
  static const String storeHome = '/store/home';
  static const String menuManagement = '/store/menu'; // メニュー管理
  static const String orderManagement = '/store/orders'; // 注文管理

  // 管理者
  static const String adminHome = '/admin/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      // 依頼側
      case requestorHome:
        return MaterialPageRoute(builder: (_) => const RequestorHomeScreen());
      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      
      // 配達側
      case delivererHome:
        return MaterialPageRoute(builder: (_) => const DelivererHomeScreen());
      case jobSearch:
        return MaterialPageRoute(builder: (_) => const JobSearchScreen());
      
      // 店舗側
      case storeHome:
        return MaterialPageRoute(builder: (_) => const StoreHomeScreen());
      case menuManagement:
        return MaterialPageRoute(builder: (_) => const MenuManagementScreen());
      case orderManagement:
        return MaterialPageRoute(builder: (_) => const OrderManagementScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}