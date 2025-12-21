import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

void main() {
  runApp(const StellarDeliveryApp());
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