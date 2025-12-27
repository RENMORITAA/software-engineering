import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';

/// 注文履歴画面
class COrderHistoryPage extends StatefulWidget {
  const COrderHistoryPage({super.key});

  @override
  State<COrderHistoryPage> createState() => _COrderHistoryPageState();
}

class _COrderHistoryPageState extends State<COrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserRoleProvider>().userId;
      if (userId != null) {
        context.read<OrderProvider>().fetchRequesterOrders(userId);
      }
    });
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
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    // 注文を分類
    final activeOrders = orders.where((order) {
      return order.status != 'delivered' && order.status != 'cancelled';
    }).toList();

    final pastOrders = orders.where((order) {
      return order.status == 'delivered' || order.status == 'cancelled';
    }).toList();

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
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 進行中の注文
                activeOrders.isEmpty
                    ? _buildEmptyState('進行中の注文はありません')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: activeOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(activeOrders[index], true);
                        },
                      ),
                // 過去の注文
                pastOrders.isEmpty
                    ? _buildEmptyState('過去の注文はありません')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pastOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(pastOrders[index], false);
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

  Widget _buildOrderCard(Order order, bool isActive) {
    final status = order.status;

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
                        '店舗ID: ${order.storeId}', // TODO: 店舗名を表示
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
                    '${order.orderDetails.length}点の商品',
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
                        order.orderedAt?.toString().split('.')[0] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '¥${order.totalPrice}',
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

  void _showOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _OrderDetailPage(order: order),
      ),
    );
  }
}

class _OrderDetailPage extends StatelessWidget {
  final Order order;

  const _OrderDetailPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
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
                    '注文番号: #${order.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '注文日時: ${order.orderedAt}',
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
                    '店舗ID: ${order.storeId}',
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
                  ...order.orderDetails.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.productName} x ${item.quantity}'),
                            Text('¥${item.unitPrice * item.quantity}'),
                          ],
                        ),
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
                        '¥${order.totalPrice}',
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
