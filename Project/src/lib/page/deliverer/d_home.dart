import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import 'd_notice.dart';

/// 配達員ホーム画面
class DHomePage extends StatefulWidget {
  const DHomePage({super.key});

  @override
  State<DHomePage> createState() => _DHomePageState();
}

class _DHomePageState extends State<DHomePage> {
  @override
  void initState() {
    super.initState();
    // 画面表示時にデータを更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchMyDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final isOnline = deliveryProvider.isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stellar Delivery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DNoticePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // オンライン/オフライン切り替え
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFFE8F5E9) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOnline ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFF2E7D32) : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'オンライン' : 'オフライン',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isOnline
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[600],
                          ),
                        ),
                        Text(
                          isOnline ? '注文を受け付けています' : '配達を開始するにはタップ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (value) {
                      deliveryProvider.toggleOnlineStatus(value);
                    },
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 今日の実績
            const Text(
              '今日の実績',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '配達件数',
                    '${deliveryProvider.myDeliveries.length}件',
                    Icons.local_shipping_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '売上',
                    '¥${deliveryProvider.myDeliveries.fold(0, (sum, item) => sum + (item.deliveryFee ?? 0))}',
                    Icons.attach_money,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 現在のステータス
            if (isOnline)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '現在、近くのエリアで注文が増加しています。',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
