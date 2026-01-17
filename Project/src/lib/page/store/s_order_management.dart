import 'package:flutter/material.dart';

import '../../component/component.dart';

/// 注文管理画面（店舗向け）
/// 注文状況の確認と状態更新機能
class SOrderManagementPage extends StatefulWidget {
  const SOrderManagementPage({super.key});

  @override
  State<SOrderManagementPage> createState() => _SOrderManagementPageState();
}

class _SOrderManagementPageState extends State<SOrderManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = '受付';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '注文管理',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // ステータスタブ
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '受付'),
                Tab(text: '準備中'),
                Tab(text: '受け渡し待ち'),
                Tab(text: '完了'),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
            ),
          ),
          // 注文リスト
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList('受付'),
                _buildOrderList('準備中'),
                _buildOrderList('受け渡し待ち'),
                _buildOrderList('完了'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    // サンプルデータ（本番環境ではAPIから取得）
    final orders = [
      {
        'id': 1001,
        'userName': '山田太郎',
        'items': '味噌ラーメン × 2\n餃子 × 1',
        'total': 3800,
        'time': '15:30',
        'notes': '味噌は濃いめでお願いします',
      },
      {
        'id': 1002,
        'userName': '鈴木花子',
        'items': 'カツ丼 × 1\n味噌汁 × 1',
        'total': 1500,
        'time': '15:45',
        'notes': '',
      },
      {
        'id': 1003,
        'userName': '佐藤次郎',
        'items': 'チャーハン × 1\n唐揚げ × 2',
        'total': 2400,
        'time': '16:00',
        'notes': '唐揚げは辛めでお願いします',
      },
    ];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '注文がありません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, status);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String currentStatus) {
    final statusColors = {
      '受付': Colors.blue,
      '準備中': Colors.orange,
      '受け渡し待ち': Colors.purple,
      '完了': Colors.green,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー：注文ID、顧客名、ステータス
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '注文 #${order['id']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['userName'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColors[currentStatus]?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColors[currentStatus] ?? Colors.grey,
                  ),
                ),
                child: Text(
                  currentStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColors[currentStatus] ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 注文内容
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '注文内容',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order['items'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 特記事項（ある場合）
          if ((order['notes'] as String).isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['notes'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if ((order['notes'] as String).isNotEmpty)
            const SizedBox(height: 12),
          // フッター：金額と時刻
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¥${order['total']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                order['time'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ステータス更新ボタン
          if (currentStatus != '完了')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showStatusUpdateDialog(order['id'] as int);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColors[currentStatus],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'ステータス更新',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(int orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ステータス更新'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('注文 #$orderId のステータスを更新します'),
              const SizedBox(height: 16),
              const Text(
                '新しいステータス',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['準備中', '受け渡し待ち', '完了'].map((status) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '注文 #$orderId を「$_selectedStatus」に更新しました',
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }
}
