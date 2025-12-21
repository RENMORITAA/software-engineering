import 'package:flutter/material.dart';

import '../../component/component.dart';
import 'd_home.dart';
import 'd_job_select.dart';
import 'd_map.dart';
import 'd_delivery_history.dart';
import 'd_mypage.dart';

/// 配達員ルートページ
class DRootPage extends StatefulWidget {
  const DRootPage({super.key});

  @override
  State<DRootPage> createState() => _DRootPageState();
}

class _DRootPageState extends State<DRootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DHomePage(),
    DJobSelectPage(),
    DMapPage(),
    DDeliveryHistoryPage(),
    DMyPageWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NormalBottomAppBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: delivererNavItems,
        selectedItemColor: const Color(0xFF2E7D32), // 配達員カラー（緑）
      ),
    );
  }
}
