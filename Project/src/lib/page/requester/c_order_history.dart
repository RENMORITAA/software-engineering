import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../component/component.dart";
import "../../models/database_models.dart";
import "../../provider/provider.dart";

/// 注文履歴
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
        return '準備中';
      case 'preparing':
        return '調理中';
      case 'ready_for_pickup':
        return '受け取り待ち';
      case 'picked_up':
        return '配達中';
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

    final activeOrders = orders
        .where((order) => order.status != 'delivered' && order.status != 'cancelled')
        .toList();
    final pastOrders = orders
        .where((order) => order.status == 'delivered' || order.status == 'cancelled')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '注文履歴',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
                activeOrders.isEmpty
                    ? _buildEmptyState('進行中の注文はありません')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: activeOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(activeOrders[index], true);
                        },
                      ),
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
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '注文ID: ${order.id ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text(_getStatusText(order.status)),
                  backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
                  labelStyle: TextStyle(color: _getStatusColor(order.status)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('合計: ¥${order.totalPrice}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.orderedAt ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPage(order: order),
                    ),
                  );
                },
                child: Text(isActive ? '進行状況を見る' : '詳細を見る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailPage extends StatelessWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  int _stepFromStatus(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'accepted':
      case 'preparing':
        return 1;
      case 'ready_for_pickup':
      case 'picked_up':
      case 'delivering':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['受付', '準備中', '配達中', '完了'];
    final currentStep = _stepFromStatus(order.status);

    return Scaffold(
      appBar: const TitleAppBar(
        title: '注文詳細',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stepper(
            currentStep: currentStep,
            controlsBuilder: (context, _) => const SizedBox.shrink(),
            steps: List.generate(steps.length, (index) {
              return Step(
                title: Text(steps[index]),
                content: const SizedBox.shrink(),
                isActive: index <= currentStep,
                state: index < currentStep ? StepState.complete : StepState.indexed,
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('配送先: ${order.deliveryAddress}'),
          const SizedBox(height: 8),
          Text('合計: ¥${order.totalPrice}'),
          const SizedBox(height: 16),
          const Text(
            '注文商品',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...order.orderDetails.map((detail) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(detail.productName),
              subtitle: Text('数量: ${detail.quantity}'),
              trailing: Text('¥${detail.subtotal}'),
            );
          }).toList(),
        ],
      ),
    );
  }
}
