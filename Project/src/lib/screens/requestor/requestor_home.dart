import 'package:flutter/material.dart';

// 図124参照: 依頼者側ホーム画面
// ボトムナビゲーションで主要機能へアクセス
class RequestorHomeScreen extends StatefulWidget {
  const RequestorHomeScreen({super.key});

  @override
  State<RequestorHomeScreen> createState() => _RequestorHomeScreenState();
}

class _RequestorHomeScreenState extends State<RequestorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),      // ホーム
    const _CartContent(),      // カート
    const _MapContent(),       // マップ
    const _NotificationContent(), // 通知
    const _MyPageContent(),    // マイページ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Delivery (依頼側)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 店舗・商品検索画面へ (図125)
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'カート'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: '通知'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }
}

// プレースホルダーウィジェット
class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('おすすめ店舗', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // ここに店舗リストを表示
        Container(height: 150, color: Colors.grey[300], child: const Center(child: Text('店舗バナー'))),
        const SizedBox(height: 20),
        const Text('カテゴリ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        // カテゴリリスト
      ],
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('カート画面 (図127)'));
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('マップ画面 (図130)\nGoogle Mapsなどを表示'));
  }
}

class _NotificationContent extends StatelessWidget {
  const _NotificationContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('通知画面 (図131)'));
  }
}

class _MyPageContent extends StatelessWidget {
  const _MyPageContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('マイページ (図110)\n会員情報、履歴、ログアウトなど'));
  }
}