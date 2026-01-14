import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'config/env_config.dart';
import 'provider/provider.dart';

void main() {
  // Web用: URLからハッシュ(#)を除去してクリーンなURLを使用
  // 例: /#/login → /login
  usePathUrlStrategy();
  
  // 起動時に環境設定を出力
  EnvConfig.printConfig();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => OverScreenController()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const StellarDeliveryApp(),
    ),
  );
}

class StellarDeliveryApp extends StatelessWidget {
  const StellarDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stellar Delivery',
      theme: AppTheme.lightTheme, // 共通テーマの適用
      
      // ルーティング設定
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRoutes.generateRoute,
      
      debugShowCheckedModeBanner: false,
    );
  }
}