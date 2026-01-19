import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../unified_mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

/// 店舗向けマイページ
class SMyPageWrapper extends StatelessWidget {
  const SMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return UnifiedMyPage(
      userName: userProvider.storeName ?? userProvider.userName ?? '店舗',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'store',
      accessToken: userProvider.accessToken ?? '',
      additionalInfo: userProvider.storeAddress != null
          ? {'住所': userProvider.storeAddress!}
          : null,
      roleSpecificSettings: [
        {
          'icon': Icons.restaurant_menu_outlined,
          'title': 'メニュー管理',
          'onTap': () {},
        },
        {
          'icon': Icons.trending_up_outlined,
          'title': '売上管理',
          'onTap': () {},
        },
        {
          'icon': Icons.store_outlined,
          'title': '営業時間設定',
          'onTap': () {},
        },
      ],
      onLogout: () async {
        await authService.logout();
        userProvider.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      onWithdraw: () async {
        await authService.logout();
        userProvider.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
    );
  }
}
