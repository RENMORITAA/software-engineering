import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../unified_mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

/// 配達員向けマイページ
class DMyPageWrapper extends StatelessWidget {
  const DMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return UnifiedMyPage(
      userName: userProvider.userName ?? '配達員',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'deliverer',
      accessToken: userProvider.accessToken ?? '',
      additionalInfo: userProvider.vehicleType != null
          ? {'配送手段': userProvider.vehicleType!}
          : null,
      roleSpecificSettings: [
        {
          'icon': Icons.local_shipping_outlined,
          'title': '配達履歴',
          'onTap': () {},
        },
        {
          'icon': Icons.verified_outlined,
          'title': '認証情報管理',
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
