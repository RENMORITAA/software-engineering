import 'package:flutter/material.dart';

import '../../component/component.dart';
import 'c_home.dart';
import 'c_product_list.dart';
import 'c_cart.dart';
import 'c_order_history.dart';
import 'c_mypage.dart';

/// 依頼者ルートページ
/// ボトムナビゲーションで各画面を切り替え
class CRootPage extends StatefulWidget {
  const CRootPage({super.key});

  @override
  State<CRootPage> createState() => _CRootPageState();
}

class _CRootPageState extends State<CRootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CHomePage(),
    CProductListPage(),
    CCartPage(),
    COrderHistoryPage(),
    CMyPageWrapper(),
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
        items: requesterNavItems,
        selectedItemColor: const Color(0xFF1A237E),
      ),
    );
  }
}
