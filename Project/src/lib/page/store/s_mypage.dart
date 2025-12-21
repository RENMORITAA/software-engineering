import 'package:flutter/material.dart';

import '../mypage.dart';

/// 店舗マイページラッパー
class SMyPageWrapper extends StatelessWidget {
  const SMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MyPage(
      userName: 'テスト食堂',
      userEmail: 'store1@test.com',
      userRole: 'store',
      onLogout: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
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
