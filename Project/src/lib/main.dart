import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';

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
      // 初期画面はログイン画面とします
      home: const LoginScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      
      debugShowCheckedModeBanner: false,
    );
  }
}