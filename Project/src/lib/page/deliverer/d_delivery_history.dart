import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';

/// 配達履歴画面
class DDeliveryHistoryPage extends StatefulWidget {
  const DDeliveryHistoryPage({super.key});

  @override
  State<DDeliveryHistoryPage> createState() => _DDeliveryHistoryPageState();
}

class _DDeliveryHistoryPageState extends State<DDeliveryHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchMyDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final deliveries = deliveryProvider.myDeliveries;

    return Scaffold(
      appBar: const TitleAppBar(
        title: '配達履歴',
        showBackButton: false,
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: deliveryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => deliveryProvider.fetchMyDeliveries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(context, deliveries[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '配達履歴がありません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Delivery delivery) {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    final timeFormat = DateFormat('HH:mm');
    final date = delivery.createdAt != null
        //? dateFormat.format(delivery.createdAt!)
        ? dateFormat.format(DateTime.parse(delivery.createdAt!))
        : '日付不明';
    final time = delivery.deliveryTime != null
        //? timeFormat.format(delivery.deliveryTime!)
        ? timeFormat.format(DateTime.parse(delivery.deliveryTime!))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(time.isNotEmpty ? time : '時刻不明'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getStatusIcon(delivery.status),
                  size: 16,
                  color: _getStatusColor(delivery.status),
                ),
                const SizedBox(width: 8),
                Text(_getStatusText(delivery.status)),
              ],
            ),
            if (delivery.distanceKm != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${delivery.distanceKm!.toStringAsFixed(1)}km'),
                ],
              ),
            ],
          ],
        ),
        trailing: Text(
          '¥${delivery.deliveryFee ?? 0}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DDeliveryHistoryDetailPage(
                delivery: delivery,
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'delivering':
        return Icons.local_shipping;
      case 'picked_up':
        return Icons.shopping_bag;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'delivering':
        return Colors.blue;
      case 'picked_up':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '配達完了';
      case 'delivering':
        return '配達中';
      case 'picked_up':
        return '商品受取済';
      case 'at_store':
        return '店舗到着';
      case 'heading_store':
        return '店舗へ向かっています';
      case 'assigned':
        return '割当済';
      default:
        return status;
    }
  }
}

/// 配達履歴詳細画面
class DDeliveryHistoryDetailPage extends StatelessWidget {
  final Delivery delivery;

  const DDeliveryHistoryDetailPage({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Scaffold(
      appBar: const TitleAppBar(
        title: '配達詳細',
        showBackButton: true,
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                delivery.status == 'completed'
                    ? Icons.check_circle
                    : Icons.local_shipping,
                size: 64,
                color: delivery.status == 'completed'
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _getStatusText(delivery.status),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            if (delivery.createdAt != null)
              _buildDetailRow(
                '配達日時',
                //dateFormat.format(delivery.createdAt!),
                dateFormat.format(DateTime.parse(delivery.createdAt!)),
              ),
            if (delivery.deliveryFee != null)
              _buildDetailRow(
                '報酬',
                '¥${delivery.deliveryFee}',
                isBold: true,
              ),
            if (delivery.distanceKm != null)
              _buildDetailRow(
                '配達距離',
                '${delivery.distanceKm!.toStringAsFixed(1)}km',
              ),
            _buildDetailRow('配達ID', 'DEL-${delivery.id}'),
            if (delivery.pickupTime != null)
              _buildDetailRow(
                '商品受取時刻',
                //DateFormat('HH:mm').format(delivery.pickupTime!),
                DateFormat('HH:mm').format(DateTime.parse(delivery.pickupTime!)),
              ),
            if (delivery.deliveryTime != null)
              _buildDetailRow(
                '配達完了時刻',
                //DateFormat('HH:mm').format(delivery.deliveryTime!),
                DateFormat('HH:mm').format(DateTime.parse(delivery.deliveryTime!)),
              ),
            const Divider(),
            const SizedBox(height: 24),
            if (delivery.currentLatitude != null &&
                delivery.currentLongitude != null) ...[
              const Text(
                '最終位置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '緯度: ${delivery.currentLatitude!.toStringAsFixed(6)}\n'
                '経度: ${delivery.currentLongitude!.toStringAsFixed(6)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return '配達完了';
      case 'delivering':
        return '配達中';
      case 'picked_up':
        return '商品受取済';
      case 'at_store':
        return '店舗到着';
      case 'heading_store':
        return '店舗へ向かっています';
      case 'assigned':
        return '割当済';
      default:
        return status;
    }
  }
}