import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';

/// 配達員マイページラッパー
class DMyPageWrapper extends StatelessWidget {
  const DMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return MyPage(
      userName: userProvider.userName ?? '配達員',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'deliverer',
      additionalInfo: userProvider.vehicleType != null
          ? {'車両タイプ': userProvider.vehicleType!}
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
