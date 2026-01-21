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
    // watchを使用しているため、状態変更時に再ビルドされます
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
      // ログアウト処理の修正
      onLogout: () async {
        // 【修正点】ここで showDialog は行わない。
        // UnifiedMyPage 側で確認ダイアログを出してからこの関数が呼ばれる設計にするため。

        try {
          // 1. サーバー側のログアウトセッション破棄
          await authService.logout();
          
          // 2. ローカルの状態（Provider）をクリア
          userProvider.logout();
          
          if (context.mounted) {
            // 3. 全ての画面履歴を消してログイン画面へ強制遷移
            // これにより、戻るボタンで「山田太郎」画面に戻るのを防ぎます
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ログアウト中にエラーが発生しました')),
            );
          }
        }
      },
      // 退会処理の修正
      onWithdraw: () async {
        // 【修正点】退会も同様に、UnifiedMyPage 側のダイアログで
        // 「はい」が押された時のみこの処理が走るようにします。

        try {
          // TODO: 実際の退会API（deleteUser等）をここで呼ぶ
          await authService.logout();
          userProvider.logout();
          
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('退会処理が完了しました')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('退会処理中にエラーが発生しました')),
            );
          }
        }
      },
    );
  }
}