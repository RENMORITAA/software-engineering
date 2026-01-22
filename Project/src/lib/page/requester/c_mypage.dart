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
    // userProviderの変更を監視し、ログアウト等の状態変化に対応
    final userProvider = context.watch<UserRoleProvider>();
    final authService = AuthService();
    
    return UnifiedMyPage(
      userName: userProvider.userName ?? '依頼者',
      userEmail: userProvider.userEmail ?? '',
      userRole: 'requester',
      accessToken: userProvider.accessToken ?? '',
      
      // --- ログアウト処理 ---
      onLogout: () async {
        try {
          // 1. サーバー側のログアウトセッション破棄（トークン無効化など）
          await authService.logout();
          
          // 2. ローカルの状態（Provider）をクリア
          userProvider.logout();
          
          if (context.mounted) {
            // 3. 全ての画面履歴を消してログイン画面へ強制遷移
            // (route) => false により、戻るボタンでマイページに戻るのを完全に防ぎます
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

      // --- 退会処理 (DB物理削除連携) ---
      onWithdraw: () async {
        try {
          // 1. 作成した withdraw() メソッドを呼び出し、
          // サーバーDBからの削除(DELETE /auth/withdraw)とログアウトを同時に実行
          await authService.withdraw(); 

          // 2. ローカルのログイン状態（Provider）をクリア
          userProvider.logout();

          // 注意: UnifiedMyPage 側の実装で、この関数の実行完了後に 
          // Navigator.pushNamedAndRemoveUntil(context, '/login', ...) 
          // が走るようになっているか確認してください。
          // もし走らない場合は、ここに Navigator 処理を追記します。

        } catch (e) {
          // エラーを再スローして UnifiedMyPage 側の SnackBar 等で表示させる
          rethrow;
        }
      },

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
    );
  }
}