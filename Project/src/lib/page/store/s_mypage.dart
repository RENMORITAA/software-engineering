import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';

/// 店舗マイページラッパー
class SMyPageWrapper extends StatelessWidget {
  const SMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return MyPage(
      userName: userProvider.storeName ?? userProvider.userName ?? '店舗',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'store',
      additionalInfo: userProvider.storeAddress != null
          ? {'住所': userProvider.storeAddress!}
          : null,
      onLogout: () async {
        await authService.logout();
        userProvider.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        }
      },
      onWithdraw: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      },
    );
  }
}
