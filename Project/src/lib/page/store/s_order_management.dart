import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../models/database_models.dart';
import '../../provider/order_provider.dart';

/// 現在の店舗ユーザー向けの注文管理画面。
/// /orders/my からデータを取得し、基本的なステータス更新を可能にします。
class SOrderManagementPage extends StatefulWidget {
  const SOrderManagementPage({super.key});

  @override
  State<SOrderManagementPage> createState() => _SOrderManagementPageState();
}

class _SOrderManagementPageState extends State<SOrderManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchStoreOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const TitleAppBar(
        title: '受注管理',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '未対応'),
                Tab(text: '準備中'),
                Tab(text: '受取可'),
                Tab(text: '完了'),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
            ),
          ),
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(orderProvider.orders, '未対応'),
                      _buildOrderList(orderProvider.orders, '準備中'),
                      _buildOrderList(orderProvider.orders, '受取可'),
                      _buildOrderList(orderProvider.orders, '完了'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> allOrders, String tabLabel) {
    final filtered = _filterByTab(allOrders, tabLabel);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('注文はありません', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildOrderCard(filtered[index], tabLabel);
      },
    );
  }

  Widget _buildOrderCard(Order order, String currentStatusLabel) {
    final statusColors = {
      '未対応': Colors.blue,
      '準備中': Colors.orange,
      '受取可': Colors.purple,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('注文番号 #${order.id ?? '-'}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('依頼者ID: ${order.requesterId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColors[currentStatusLabel]?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColors[currentStatusLabel] ?? Colors.grey),
                ),
                child: Text(
                  currentStatusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColors[currentStatusLabel] ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('商品詳細', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                ...order.orderDetails.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${d.productName} x${d.quantity} (単価: ${d.unitPrice})',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if ((order.notes ?? '').isNotEmpty)
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
                  Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.notes ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('合計', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('注文日時', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.totalPrice}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(order.orderedAt ?? '-', style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    final buttons = <Widget>[];

    if (order.id == null) {
      return const SizedBox.shrink();
    }

    void add(String label, Color color, String nextStatus, String displayStatus) {
      buttons.add(
        _buildActionButton(label, color, () async {
          final ok = await context.read<OrderProvider>().updateOrderStatus(order.id!, nextStatus);
          if (!mounted) return;
          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ステータスを「$displayStatus」に更新しました')),
            );
            context.read<OrderProvider>().fetchStoreOrders();
          } else {
            final err = context.read<OrderProvider>().error ?? '更新に失敗しました';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
          }
        }),
      );
    }

    switch (order.status) {
      case 'pending':
        add('注文を承認', Colors.blue, 'accepted', '承認済み');
        add('キャンセル', Colors.red, 'cancelled', 'キャンセル');
        break;
      case 'accepted':
        add('準備を開始', Colors.orange, 'preparing', '準備中');
        break;
      case 'preparing':
        add('準備完了', Colors.purple, 'ready_for_pickup', '受取可');
        break;
      case 'ready_for_pickup':
        add('配達・受渡完了', Colors.green, 'delivered', '完了');
        break;
      default:
        break;
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: buttons
          .map((b) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: b)))
          .toList(),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  List<Order> _filterByTab(List<Order> orders, String tab) {
    switch (tab) {
      case '未対応':
        return orders.where((o) => o.status == 'pending' || o.status == 'accepted').toList();
      case '準備中':
        return orders.where((o) => o.status == 'preparing').toList();
      case '受取可':
        return orders.where((o) => o.status == 'ready_for_pickup').toList();
      case '完了':
        return orders.where((o) => o.status == 'delivered' || o.status == 'cancelled').toList();
      default:
        return orders;
    }
  }
}