import 'package:flutter/material.dart';

// 図140参照: 配達側ホーム画面
class DelivererHomeScreen extends StatefulWidget {
  const DelivererHomeScreen({super.key});

  @override
  State<DelivererHomeScreen> createState() => _DelivererHomeScreenState();
}

class _DelivererHomeScreenState extends State<DelivererHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(), // ホーム (現在の配達状況など)
    const _JobSearchContent(), // 求人検索
    const _MapContent(), // マップ
    const _HistoryContent(), // 受注・履歴
    const _MyPageContent(), // マイページ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配達パートナー'),
        backgroundColor: Colors.green[700], // 配達側は色を変えても良い
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '求人検索'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '受注/履歴'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('現在稼働中...\n直近の配達内容を表示 (図140)'));
  }
}

class _JobSearchContent extends StatelessWidget {
  const _JobSearchContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('求人検索 (図141)'));
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('マップ・ルート確認 (図144)'));
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('受注一覧・履歴 (図147/159)'));
  }
}

class _MyPageContent extends StatelessWidget {
  const _MyPageContent();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('マイページ (図153)\n給与明細、履歴書など'));
  }
}