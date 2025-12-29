import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';

/// 注文追跡画面
class COrderTrackingPage extends StatefulWidget {
  final int orderId;

  const COrderTrackingPage({super.key, required this.orderId});

  @override
  State<COrderTrackingPage> createState() => _COrderTrackingPageState();
}

class _COrderTrackingPageState extends State<COrderTrackingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '注文確認中';
      case 'accepted':
        return '店舗が注文を受け付けました';
      case 'preparing':
        return '調理中です';
      case 'ready_for_pickup':
        return '配達員を待っています';
      case 'picked_up':
        return '配達員が商品を受け取りました';
      case 'delivering':
        return '配達中です';
      case 'delivered':
        return '配達完了';
      case 'cancelled':
        return 'キャンセルされました';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'お店が注文を確認しています。しばらくお待ちください。';
      case 'accepted':
        return 'お店が注文を受け付けました。調理を開始します。';
      case 'preparing':
        return 'お店で料理を準備中です。もう少しお待ちください。';
      case 'ready_for_pickup':
        return '料理が完成しました。配達員が受け取りに向かっています。';
      case 'picked_up':
        return '配達員が商品を受け取り、あなたの元へ向かっています。';
      case 'delivering':
        return '配達員が配達中です。まもなく到着します。';
      case 'delivered':
        return 'ご注文の品が届きました。ご利用ありがとうございます。';
      case 'cancelled':
        return 'この注文はキャンセルされました。';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready_for_pickup':
        return Icons.inventory_2;
      case 'picked_up':
        return Icons.person;
      case 'delivering':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.home;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
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
    final order = orderProvider.currentOrder;

    return Scaffold(
      appBar: const TitleAppBar(
        title: '注文を追跡',
        showBackButton: true,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? _buildErrorState()
              : _buildTrackingContent(order),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '注文が見つかりません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(Order order) {
    final status = order.status;
    final statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 地図プレースホルダー
          Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '配達位置を追跡中...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // ステータス表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusDescription(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 進捗バー
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildProgressSteps(status),
          ),
          // 注文詳細
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '注文詳細',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('注文番号'),
                    Text('#${order.id}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('店舗'),
                    Text('店舗ID: ${order.storeId}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('合計金額'),
                    Text(
                      '¥${order.totalPrice}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 配達先
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '配達先',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // アクションボタン
          if (status != 'delivered' && status != 'cancelled')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: サポートに連絡
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('サポートに連絡'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // リフレッシュ
                        context
                            .read<OrderProvider>()
                            .fetchOrderDetail(widget.orderId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('更新'),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProgressSteps(String currentStatus) {
    final steps = [
      {'status': 'accepted', 'label': '受付'},
      {'status': 'preparing', 'label': '調理'},
      {'status': 'picked_up', 'label': '受取'},
      {'status': 'delivered', 'label': '配達'},
    ];

    final statusOrder = [
      'pending',
      'accepted',
      'preparing',
      'ready_for_pickup',
      'picked_up',
      'delivering',
      'delivered'
    ];
    final currentIndex = statusOrder.indexOf(currentStatus);

    return Row(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final stepIndex = statusOrder.indexOf(step['status']!);
        final isCompleted = currentIndex >= stepIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? Colors.black87 : Colors.grey[400],
                        fontWeight:
                            isCompleted ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 24),
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
}
