import 'package:flutter/material.dart';

import '../mypage.dart';

/// 配達員マイページラッパー
class DMyPageWrapper extends StatelessWidget {
  const DMyPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MyPage(
      userName: '佐藤 一郎',
      userEmail: 'deliverer1@test.com',
      userRole: 'deliverer',
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
