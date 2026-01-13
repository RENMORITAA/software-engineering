import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

/// 依頼者マイページラッパー
class CMyPageWrapper extends StatelessWidget {
  const CMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return MyPage(
      userName: userProvider.userName ?? '依頼者',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'requester',
      onLogout: () async {
        // ログアウト処理（トークンとユーザー情報をクリア）
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
        // 退会処理
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
