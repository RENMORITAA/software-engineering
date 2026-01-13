import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/location_provider.dart';
import '../../widgets/map_widget.dart';
import '../../services/location_service.dart';

/// 配達追跡画面（注文者用）
class OrderTrackingPage extends StatefulWidget {
  final int orderId;
  final String? delivererName;
  final String? storeName;
  final String? deliveryAddress;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    this.delivererName,
    this.storeName,
    this.deliveryAddress,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // 配達状態
  String _deliveryStatus = 'picking_up'; // picking_up, on_the_way, arriving
  
  // 配達員の模擬位置
  LocationData? _delivererLocation;
  
  // 目的地（配達先）
  final LocationData _destination = LocationData(
    latitude: 33.5960,
    longitude: 133.8640,
  );

  @override
  void initState() {
    super.initState();
    _startTrackingSimulation();
  }

  void _startTrackingSimulation() {
    // 実際のアプリでは、サーバーから配達員の位置を定期的に取得
    // ここではデモ用のシミュレーション
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _delivererLocation = LocationData(
            latitude: 33.5944,
            longitude: 133.8628,
          );
        });
      }
    });

    // 定期的に位置を更新（デモ）
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _deliveryStatus = 'on_the_way';
          _delivererLocation = LocationData(
            latitude: 33.5950,
            longitude: 133.8633,
          );
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _deliveryStatus = 'arriving';
          _delivererLocation = LocationData(
            latitude: 33.5958,
            longitude: 133.8638,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配達追跡'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 地図
          Expanded(
            flex: 3,
            child: DeliveryTrackingMap(
              delivererLocation: _delivererLocation,
              destinationLocation: _destination,
              delivererName: widget.delivererName ?? '配達員',
              estimatedArrival: _getEstimatedArrival(),
            ),
          ),

          // 配達情報パネル
          Expanded(
            flex: 2,
            child: _buildInfoPanel(),
          ),
        ],
      ),
    );
  }

  String _getEstimatedArrival() {
    if (_delivererLocation == null) return '計算中...';
    
    final distance = LocationService.calculateDistance(
      _delivererLocation!.latitude,
      _delivererLocation!.longitude,
      _destination.latitude,
      _destination.longitude,
    );
    
    return LocationService.estimateArrivalTime(distance);
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配達ステータス
          _buildStatusIndicator(),
          const SizedBox(height: 20),

          // 注文情報
          Row(
            children: [
              const Icon(Icons.store, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.storeName ?? '店舗',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '注文番号: #${widget.orderId}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // 配達先
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'お届け先',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.deliveryAddress ?? '配達先住所',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // アクションボタン
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('配達員に連絡中...')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('配達員に連絡'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('閉じる'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        _buildStatusStep(
          icon: Icons.receipt,
          label: '注文受付',
          isActive: true,
          isComplete: true,
        ),
        _buildStatusLine(isComplete: _deliveryStatus != 'picking_up'),
        _buildStatusStep(
          icon: Icons.restaurant,
          label: '商品受取',
          isActive: _deliveryStatus == 'picking_up',
          isComplete: _deliveryStatus == 'on_the_way' || _deliveryStatus == 'arriving',
        ),
        _buildStatusLine(isComplete: _deliveryStatus == 'arriving'),
        _buildStatusStep(
          icon: Icons.delivery_dining,
          label: '配達中',
          isActive: _deliveryStatus == 'on_the_way',
          isComplete: _deliveryStatus == 'arriving',
        ),
        _buildStatusLine(isComplete: false),
        _buildStatusStep(
          icon: Icons.home,
          label: 'お届け',
          isActive: _deliveryStatus == 'arriving',
          isComplete: false,
        ),
      ],
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isComplete,
  }) {
    final color = isComplete
        ? Colors.green
        : isActive
            ? Colors.orange
            : Colors.grey[300];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(
            isComplete ? Icons.check : icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive || isComplete ? Colors.black : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusLine({required bool isComplete}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isComplete ? Colors.green : Colors.grey[300],
      ),
    );
  }
}
