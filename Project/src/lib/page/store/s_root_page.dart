import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../config/routes.dart';
import '../../utils/url_helper.dart';
import 's_home.dart';
import 's_order_list.dart';
import 's_menu_edit.dart';
import 's_mypage.dart';

/// 店舗側ルートページ
class SRootPage extends StatefulWidget {
  final int initialIndex;
  
  const SRootPage({super.key, this.initialIndex = 0});

  @override
  State<SRootPage> createState() => _SRootPageState();
}

class _SRootPageState extends State<SRootPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    SHomePage(),
    SOrderListPage(),
    SMenuEditPage(),
    SMyPageWrapper(),
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
    if (index >= 0 && index < AppRoutes.storeRoutes.length) {
      // ブラウザのURLを直接更新（Flutterのナビゲーションを使わない）
      UrlHelper.replaceUrl(AppRoutes.storeRoutes[index]);
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
        items: storeNavItems,
        selectedItemColor: const Color(0xFFE65100), // 店舗カラー（オレンジ）
      ),
    );
  }
}
