import 'package:flutter/material.dart';

import '../../component/component.dart';
import 's_home.dart';
import 's_order_list.dart';
import 's_menu_edit.dart';
import 's_mypage.dart';

/// 店舗側ルートページ
class SRootPage extends StatefulWidget {
  const SRootPage({super.key});

  @override
  State<SRootPage> createState() => _SRootPageState();
}

class _SRootPageState extends State<SRootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SHomePage(),
    SOrderListPage(),
    SMenuEditPage(),
    SMyPageWrapper(),
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
        items: storeNavItems,
        selectedItemColor: const Color(0xFFE65100), // 店舗カラー（オレンジ）
      ),
    );
  }
}
