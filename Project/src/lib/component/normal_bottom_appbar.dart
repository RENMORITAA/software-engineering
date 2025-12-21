import 'package:flutter/material.dart';

/// 通常のボトムナビゲーションバー
/// 各ロールで共通して使用
class NormalBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const NormalBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ?? Colors.white,
      selectedItemColor: selectedItemColor ?? Theme.of(context).primaryColor,
      unselectedItemColor: unselectedItemColor ?? Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

/// ボトムナビゲーションアイテム
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// 依頼者用ボトムナビゲーションアイテム
List<BottomNavItem> get requesterNavItems => const [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'ホーム',
      ),
      BottomNavItem(
        icon: Icons.search,
        activeIcon: Icons.search,
        label: '探す',
      ),
      BottomNavItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: 'カート',
      ),
      BottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: '注文履歴',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'マイページ',
      ),
    ];

/// 配達員用ボトムナビゲーションアイテム
List<BottomNavItem> get delivererNavItems => const [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'ホーム',
      ),
      BottomNavItem(
        icon: Icons.work_outline,
        activeIcon: Icons.work,
        label: '求人',
      ),
      BottomNavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: '配達',
      ),
      BottomNavItem(
        icon: Icons.history,
        activeIcon: Icons.history,
        label: '履歴',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'マイページ',
      ),
    ];

/// 店舗用ボトムナビゲーションアイテム
List<BottomNavItem> get storeNavItems => const [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'ホーム',
      ),
      BottomNavItem(
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt,
        label: '注文',
      ),
      BottomNavItem(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu,
        label: 'メニュー',
      ),
      BottomNavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: '売上',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'マイページ',
      ),
    ];
