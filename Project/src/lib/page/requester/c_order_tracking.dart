import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';
import '../../widgets/widgets.dart';
import '../../services/delivery_simulation_service.dart';
import '../../services/location_service.dart';

/// 注文追跡画面（Leaflet地図統合版）
class COrderTrackingPage extends StatefulWidget {
  final int orderId;

  const COrderTrackingPage({super.key, required this.orderId});

  @override
  State<COrderTrackingPage> createState() => _COrderTrackingPageState();
}

class _COrderTrackingPageState extends State<COrderTrackingPage> {
  final DeliverySimulationService _simulationService = DeliverySimulationService();
  Stream<LocationData>? _delivererLocationStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
      _startDeliveryTracking();
    });
  }

  @override
  void dispose() {
    _simulationService.dispose();
    super.dispose();
  }

  void _startDeliveryTracking() {
    // デモ用の座標でシミュレーション開始（高知県香美市）
    _delivererLocationStream = _simulationService.startSimulation(
      startLat: 33.5944, // 店舗位置（高知工科大学付近）
      startLng: 133.8628,
      endLat: 33.5850, // 依頼者位置（香美市内）
      endLng: 133.8750,
      updateIntervalSeconds: 3,
    );
    setState(() {});
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '豕ｨ譁・｢ｺ隱堺ｸｭ';
      case 'accepted':
        return '蠎苓・縺梧ｳｨ譁・ｒ蜿励￠莉倥￠縺ｾ縺励◆';
      case 'preparing':
        return '隱ｿ逅・ｸｭ縺ｧ縺・;
      case 'ready_for_pickup':
        return '驟埼＃蜩｡繧貞ｾ・▲縺ｦ縺・∪縺・;
      case 'picked_up':
        return '驟埼＃蜩｡縺悟膚蜩√ｒ蜿励￠蜿悶ｊ縺ｾ縺励◆';
      case 'delivering':
        return '驟埼＃荳ｭ縺ｧ縺・;
      case 'delivered':
        return '驟埼＃螳御ｺ・;
      case 'cancelled':
        return '繧ｭ繝｣繝ｳ繧ｻ繝ｫ縺輔ｌ縺ｾ縺励◆';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return '縺雁ｺ励′豕ｨ譁・ｒ遒ｺ隱阪＠縺ｦ縺・∪縺吶ゅ＠縺ｰ繧峨￥縺雁ｾ・■縺上□縺輔＞縲・;
      case 'accepted':
        return '縺雁ｺ励′豕ｨ譁・ｒ蜿励￠莉倥￠縺ｾ縺励◆縲りｪｿ逅・ｒ髢句ｧ九＠縺ｾ縺吶・;
      case 'preparing':
        return '縺雁ｺ励〒譁咏炊繧呈ｺ門ｙ荳ｭ縺ｧ縺吶ゅｂ縺・ｰ代＠縺雁ｾ・■縺上□縺輔＞縲・;
      case 'ready_for_pickup':
        return '譁咏炊縺悟ｮ梧・縺励∪縺励◆縲る・驕泌藤縺悟女縺大叙繧翫↓蜷代°縺｣縺ｦ縺・∪縺吶・;
      case 'picked_up':
        return '驟埼＃蜩｡縺悟膚蜩√ｒ蜿励￠蜿悶ｊ縲√≠縺ｪ縺溘・蜈・∈蜷代°縺｣縺ｦ縺・∪縺吶・;
      case 'delivering':
        return '驟埼＃蜩｡縺碁・驕比ｸｭ縺ｧ縺吶ゅ∪繧ゅ↑縺丞芦逹縺励∪縺吶・;
      case 'delivered':
        return '縺疲ｳｨ譁・・蜩√′螻翫″縺ｾ縺励◆縲ゅ＃蛻ｩ逕ｨ縺ゅｊ縺後→縺・＃縺悶＞縺ｾ縺吶・;
      case 'cancelled':
        return '縺薙・豕ｨ譁・・繧ｭ繝｣繝ｳ繧ｻ繝ｫ縺輔ｌ縺ｾ縺励◆縲・;
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
        title: '豕ｨ譁・ｒ霑ｽ霍｡',
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
            '豕ｨ譁・′隕九▽縺九ｊ縺ｾ縺帙ｓ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('謌ｻ繧・),
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
          // 蝨ｰ蝗ｳ繝励Ξ繝ｼ繧ｹ繝帙Ν繝繝ｼ
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
                    '驟埼＃菴咲ｽｮ繧定ｿｽ霍｡荳ｭ...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // 繧ｹ繝・・繧ｿ繧ｹ陦ｨ遉ｺ
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
          // 騾ｲ謐励ヰ繝ｼ
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildProgressSteps(status),
          ),
          // 豕ｨ譁・ｩｳ邏ｰ
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
                  '豕ｨ譁・ｩｳ邏ｰ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('豕ｨ譁・分蜿ｷ'),
                    Text('#${order.id}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('蠎苓・'),
                    Text('蠎苓・ID: ${order.storeId}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('蜷郁ｨ磯≡鬘・),
                    Text(
                      'ﾂ･${order.totalPrice}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 驟埼＃蜈・
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
                  '驟埼＃蜈・,
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
          // 繧｢繧ｯ繧ｷ繝ｧ繝ｳ繝懊ち繝ｳ
          if (status != 'delivered' && status != 'cancelled')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: 繧ｵ繝昴・繝医↓騾｣邨｡
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('繧ｵ繝昴・繝医↓騾｣邨｡'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 繝ｪ繝輔Ξ繝・す繝･
                        context
                            .read<OrderProvider>()
                            .fetchOrderDetail(widget.orderId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('譖ｴ譁ｰ'),
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
      {'status': 'accepted', 'label': '蜿嶺ｻ・},
      {'status': 'preparing', 'label': '隱ｿ逅・},
      {'status': 'picked_up', 'label': '蜿怜叙'},
      {'status': 'delivered', 'label': '驟埼＃'},
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
