import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../unified_mypage.dart';
import '../../provider/provider.dart';
import '../../services/auth_service.dart';
import '../../config/routes.dart';



/// 依頼者向けマイページラッパー
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('住所管理機能は準備中です')),
            );
          },
        },
        {
          'icon': Icons.payment,
          'title': 'お支払い方法',
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('お支払い方法の設定は準備中です')),
            );
          },
        },
        {
          'icon': Icons.receipt_long,
          'title': '注文履歴',
          'onTap': () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('注文履歴の表示は準備中です')),
            );
          },
        },
      ],
      onLogout: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ログアウト'),
            content: const Text('ログアウトしてもよろしいですか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ログアウト'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await authService.logout();
          userProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        }
      },
      onWithdraw: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退会'),
            content: const Text(
              '退会すると、すべてのデータが削除されます。\nこの操作は取り消せません。\n本当に退会しますか？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('退会する'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // TODO: 退会API呼び出し
          await authService.logout();
          userProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('退会しました')),
            );
          }
        }
      },
    );
  }
}