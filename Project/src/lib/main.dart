import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRoleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OverScreenController()),
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
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      
      debugShowCheckedModeBanner: false,
    );
  }
}