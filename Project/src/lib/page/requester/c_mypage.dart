import 'package:flutter/material.dart';

import '../mypage.dart';

/// 依頼者マイページラッパー
class CMyPageWrapper extends StatelessWidget {
  const CMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MyPage(
      userName: '山田 太郎',
      userEmail: 'user1@test.com',
      userRole: 'requester',
      onLogout: () {
        // ログアウト処理
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      },
      onWithdraw: () {
        // 退会処理
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      },
    );
  }
}
