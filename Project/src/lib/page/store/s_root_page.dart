import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../component/normal_bottom_appbar.dart';
import '../../config/routes.dart';
import '../../utils/url_helper.dart';
import 's_home.dart';
import 's_order_management.dart';
import 's_menu_edit.dart';
import 's_mypage.dart';

import 's_sales.dart'; 

/// 店舗側ルートページ
class SRootPage extends StatefulWidget {
  final int initialIndex;
  
  const SRootPage({super.key, this.initialIndex = 0});

  @override
  State<SRootPage> createState() => _SRootPageState();
}

class _SRootPageState extends State<SRootPage> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const SHomePage(),
    const SOrderManagementPage(),
    const SMenuEditPage(),
    const SSalesPage(),             // （売上）
    const SMyPageWrapper(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // 初期URL設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUrl(_currentIndex);
    });
  }

  void _updateUrl(int index) {
    if (index >= 0 && index < AppRoutes.storeRoutes.length) {
      // 繝悶Λ繧ｦ繧ｶ縺ｮURL繧堤峩謗･譖ｴ譁ｰ・・lutter縺ｮ繝翫ン繧ｲ繝ｼ繧ｷ繝ｧ繝ｳ繧剃ｽｿ繧上↑縺・ｼ・
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
        selectedItemColor: const Color(0xFFE65100), // 蠎苓・繧ｫ繝ｩ繝ｼ・医が繝ｬ繝ｳ繧ｸ・・
      ),
    );
  }
}
