import 'package:flutter/material.dart';

import '../../component/component.dart';

/// 注文履歴画面
class COrderHistoryPage extends StatefulWidget {
  const COrderHistoryPage({super.key});

  @override
  State<COrderHistoryPage> createState() => _COrderHistoryPageState();
}

class _COrderHistoryPageState extends State<COrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // モックデータ
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': 1,
      'store': 'テスト食堂',
      'status': 'preparing',
      'total': 1600,
      'items': ['カツ丼', '親子丼'],
      'orderedAt': '2025-12-21 12:30',
    },
  ];

  final List<Map<String, dynamic>> _pastOrders = [
    {
      'id': 2,
      'store': 'カフェ モカ',
      'status': 'delivered',
      'total': 1200,
      'items': ['コーヒー', 'ケーキセット'],
      'orderedAt': '2025-12-20 14:00',
    },
    {
      'id': 3,
      'store': 'ラーメン太郎',
      'status': 'delivered',
      'total': 900,
      'items': ['とんこつラーメン'],
      'orderedAt': '2025-12-19 19:30',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '受付待ち';
      case 'accepted':
        return '受付済み';
      case 'preparing':
        return '調理中';
      case 'ready_for_pickup':
        return '受け取り待ち';
      case 'picked_up':
        return '配達員受取済';
      case 'delivering':
        return '配達中';
      case 'delivered':
        return '配達完了';
      case 'cancelled':
        return 'キャンセル';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'preparing':
        return Colors.blue;
      case 'ready_for_pickup':
      case 'picked_up':
        return Colors.purple;
      case 'delivering':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '注文履歴',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '進行中'),
            Tab(text: '過去の注文'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 進行中の注文
          _activeOrders.isEmpty
              ? _buildEmptyState('進行中の注文はありません')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_activeOrders[index], true);
                  },
                ),
          // 過去の注文
          _pastOrders.isEmpty
              ? _buildEmptyState('過去の注文はありません')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pastOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(_pastOrders[index], false);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isActive) {
    final status = order['status'] as String;

    return GestureDetector(
      onTap: () {
        _showOrderDetail(order);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['store'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 注文内容
                  Text(
                    (order['items'] as List).join(', '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 日時と金額
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['orderedAt'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '¥${order['total']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 進行中の場合はステータスバーを表示
            if (isActive) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildProgressBar(status),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String status) {
    final steps = ['受付', '調理', '配達', '完了'];
    int currentStep = 0;

    switch (status) {
      case 'pending':
        currentStep = 0;
        break;
      case 'accepted':
      case 'preparing':
        currentStep = 1;
        break;
      case 'ready_for_pickup':
      case 'picked_up':
      case 'delivering':
        currentStep = 2;
        break;
      case 'delivered':
        currentStep = 3;
        break;
    }

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isCompleted ? Colors.black87 : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _OrderDetailPage(order: order),
      ),
    );
  }
}

class _OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: '注文詳細',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 注文番号
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '注文番号: #${order['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '注文日時: ${order['orderedAt']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 店舗情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.store, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order['store'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 注文内容
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '注文内容',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(order['items'] as List).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('・$item'),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '合計',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '¥${order['total']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
