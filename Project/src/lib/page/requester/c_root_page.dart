import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../config/routes.dart';
import '../../utils/url_helper.dart';
import 'c_home.dart';
import 'c_product_list.dart';
import 'c_cart.dart';
import 'c_order_history.dart';
import 'c_mypage.dart';

/// 依頼者ルートページ
/// ボトムナビゲーションで各画面を切り替え
class CRootPage extends StatefulWidget {
  final int initialIndex;
  
  const CRootPage({super.key, this.initialIndex = 0});

  @override
  State<CRootPage> createState() => _CRootPageState();
}

class _CRootPageState extends State<CRootPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    CHomePage(),
    CProductListPage(),
    CCartPage(),
    COrderHistoryPage(),
    CMyPageWrapper(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // 初期URLを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUrl(_currentIndex);
    });
  }

  void _updateUrl(int index) {
    if (index >= 0 && index < AppRoutes.requesterRoutes.length) {
      // ブラウザのURLを直接更新（Flutterのナビゲーションを使わない）
      UrlHelper.replaceUrl(AppRoutes.requesterRoutes[index]);
    }
  }

  void _onTabTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _updateUrl(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NormalBottomAppBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: requesterNavItems,
        selectedItemColor: const Color(0xFF1A237E),
      ),
    );
  }
}
