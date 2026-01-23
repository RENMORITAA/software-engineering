import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/provider.dart';
import '../../models/database_models.dart';
import 's_inventory_status.dart';
import 's_sales.dart';
import 's_mypage.dart';

/// 店舗ホームページ（実データ版）
/// 今日のサマリーと売上分析を実データで表示
class SHomePage extends StatefulWidget {
  const SHomePage({super.key});

  @override
  State<SHomePage> createState() => _SHomePageState();
}

class _SHomePageState extends State<SHomePage> {
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    // 注文データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchStoreOrders();
    });
  }

  // 今日の注文を取得
  List<Order> _getTodayOrders(List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return orders.where((order) {
      if (order.orderedAt == null) return false;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
        return orderDay == today && order.status != 'cancelled';
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // 合計売上を計算
  int _calculateTotalSales(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + (order.totalPrice ?? 0));
  }

  // 数値フォーマット
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserRoleProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final storeName = userProvider.storeName ?? '店舗名未設定';
    
    // 今日の注文データを取得
    final todayOrders = _getTodayOrders(orderProvider.orders);
    final todaySales = _calculateTotalSales(todayOrders);
    final todayOrderCount = todayOrders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Delivery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () { // ← ★ onPressed: を追加
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SMyPageWrapper()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderProvider>().fetchStoreOrders();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  storeName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              // 営業ステータスカード
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isOpen ? const Color(0xFFFFF3E0) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isOpen ? const Color(0xFFE65100) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isOpen ? const Color(0xFFE65100) : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOpen ? '営業中' : '準備中',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isOpen ? const Color(0xFFE65100) : Colors.grey[600],
                            ),
                          ),
                          Text(
                            _isOpen ? '注文を受け付けています' : '注文受付を停止中',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOpen,
                      onChanged: (value) => setState(() => _isOpen = value),
                      activeColor: const Color(0xFFE65100),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 今日のサマリー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '今日のサマリー',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (orderProvider.isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '売上高',
                      '¥${_formatNumber(todaySales)}',
                      Icons.attach_money,
                      Colors.orange,
                      orderProvider.isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '注文数',
                      '$todayOrderCount件',
                      Icons.receipt_long,
                      Colors.blue,
                      orderProvider.isLoading,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text(
                'クイックアクション',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    '在庫管理',
                    Icons.inventory,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SInventoryStatusPage()),
                      );
                    },
                  ),
                  _buildActionCard(
                    '売上分析',
                    Icons.analytics,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SSalesPage()),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 最近の注文
              if (todayOrders.isNotEmpty) ...[
                const Text(
                  '最近の注文',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...todayOrders.take(3).map((order) => _buildRecentOrderCard(order)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          if (isLoading)
            const SizedBox(
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(Order order) {
    final statusColors = {
      'pending': Colors.blue,
      'accepted': Colors.blue,
      'preparing': Colors.orange,
      'ready_for_pickup': Colors.purple,
      'picked_up': Colors.teal,
      'delivering': Colors.teal,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };

    final statusLabels = {
      'pending': '未対応',
      'accepted': '承認済み',
      'preparing': '準備中',
      'ready_for_pickup': '受取可',
      'picked_up': '受取済み',
      'delivering': '配達中',
      'delivered': '完了',
      'cancelled': 'キャンセル',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColors[order.status]?.withOpacity(0.1) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt,
              color: statusColors[order.status] ?? Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '注文 #${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabels[order.status] ?? order.status ?? '不明',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColors[order.status] ?? Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '¥${_formatNumber(order.totalPrice ?? 0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}