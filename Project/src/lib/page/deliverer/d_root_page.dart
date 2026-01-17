import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../config/routes.dart';
import '../../utils/url_helper.dart';
import 'd_home.dart';
import 'd_job_select.dart';
import 'd_delivery_map.dart';
import 'd_delivery_history.dart';
import 'd_mypage.dart';

/// 配達員ルートページ
class DRootPage extends StatefulWidget {
  final int initialIndex;
  
  const DRootPage({super.key, this.initialIndex = 0});

  @override
  State<DRootPage> createState() => _DRootPageState();
}

class _DRootPageState extends State<DRootPage> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const DHomePage(),
    const DJobSelectPage(),
    const DDeliveryMapPage(),
    const DDeliveryHistoryPage(),
    const DMyPageWrapper(),
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
    if (index >= 0 && index < AppRoutes.delivererRoutes.length) {
      // ブラウザのURLを直接更新�E�Elutterのナビゲーションを使わなぁE��E
      UrlHelper.replaceUrl(AppRoutes.delivererRoutes[index]);
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
        items: delivererNavItems,
        selectedItemColor: const Color(0xFF2E7D32), // 配達員カラー�E�緑！E
      ),
    );
  }
}
