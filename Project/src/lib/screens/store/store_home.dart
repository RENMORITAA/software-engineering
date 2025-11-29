import 'package:flutter/material.dart';

// 図172参照: 店舗側業務画面
class StoreHomeScreen extends StatelessWidget {
  const StoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('店舗管理画面'),
        backgroundColor: Colors.orange[800],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _MenuButton(
            icon: Icons.restaurant_menu,
            label: 'メニュー管理',
            onTap: () {
              // メニュー情報変更選択画面 (図173)
            },
          ),
          _MenuButton(
            icon: Icons.inventory,
            label: '在庫ステータス',
            onTap: () {
              // 在庫ステータス変更画面 (図177)
            },
          ),
          _MenuButton(
            icon: Icons.list_alt,
            label: '注文管理',
            // バッジなどで新規注文数を表示すると良い
            onTap: () {
              // 注文管理画面 (図178)
            },
          ),
          _MenuButton(
            icon: Icons.attach_money,
            label: '売上確認',
            onTap: () {
              // 売上確認機能 (図52/183)
            },
          ),
          _MenuButton(
            icon: Icons.store,
            label: '店舗情報編集',
            onTap: () {
              // 店舗情報確認・編集画面 (図186)
            },
          ),
          _MenuButton(
            icon: Icons.settings,
            label: '設定/ログアウト',
            onTap: () {
              // マイページ/設定
            },
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.orange[800]),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}