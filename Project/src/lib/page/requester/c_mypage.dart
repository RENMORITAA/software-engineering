import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../unified_mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';

import 'c_address_edit.dart';

/// 依頼者向けマイページ
class CMyPageWrapper extends StatelessWidget {
  const CMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return UnifiedMyPage(
      userName: userProvider.userName ?? '依頼者',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'requester',
      accessToken: userProvider.accessToken ?? '',
      roleSpecificSettings: [
        {
          'icon': Icons.location_on_outlined,
          'title': '住所管理',
          'onTap': () {
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddressEditPage(
                    initialAddress: '',
                    userRole: 'requester',
                  ),
                ),
              );
            },

          },
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
