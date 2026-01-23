import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../component/component.dart';
import '../../models/database_models.dart';
import '../../provider/order_provider.dart';

/// 店舗向け売上管理ダッシュボード（実データ版）
/// 実際の注文データから本日、週間、月間の売上を集計・分析
class SSalesPage extends StatefulWidget {
  const SSalesPage({super.key});

  @override
  State<SSalesPage> createState() => _SSalesPageState();
}

class _SSalesPageState extends State<SSalesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchStoreOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // 今週の注文を取得
  List<Order> _getWeekOrders(List<Order> orders) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return orders.where((order) {
      if (order.orderedAt == null) return false;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        return orderDate.isAfter(weekStartDay) && order.status != 'cancelled';
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // 今月の注文を取得
  List<Order> _getMonthOrders(List<Order> orders) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    return orders.where((order) {
      if (order.orderedAt == null) return false;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        return orderDate.isAfter(monthStart) && order.status != 'cancelled';
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // 合計売上を計算
  int _calculateTotalSales(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + (order.totalPrice ?? 0));
  }

  // 平均単価を計算
  int _calculateAveragePrice(List<Order> orders) {
    if (orders.isEmpty) return 0;
    return _calculateTotalSales(orders) ~/ orders.length;
  }

  // 前日比/前週比/前月比を計算
  String _calculateGrowthRate(List<Order> currentOrders, List<Order> previousOrders) {
    final currentSales = _calculateTotalSales(currentOrders);
    final previousSales = _calculateTotalSales(previousOrders);
    
    if (previousSales == 0) return currentSales > 0 ? '+100%' : '0%';
    
    final rate = ((currentSales - previousSales) / previousSales * 100).round();
    return rate >= 0 ? '+$rate%' : '$rate%';
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders;
    final todayOrders = _getTodayOrders(allOrders);

    return Scaffold(
      appBar: const TitleAppBar(
        title: '売上管理',
        showBackButton: true,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // サマリーカード
                _buildSummaryCard(todayOrders, allOrders),
                // タブ
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '本日'),
                      Tab(text: '週間'),
                      Tab(text: '月間'),
                    ],
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.orange,
                  ),
                ),
                // タブ内容
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyView(todayOrders, allOrders),
                      _buildWeeklyView(allOrders),
                      _buildMonthlyView(allOrders),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(List<Order> todayOrders, List<Order> allOrders) {
    final totalSales = _calculateTotalSales(todayOrders);
    final orderCount = todayOrders.length;
    final averagePrice = _calculateAveragePrice(todayOrders);
    
    // 前日の注文を取得して伸率を計算
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final yesterdayEnd = yesterdayStart.add(const Duration(days: 1));
    
    final yesterdayOrders = allOrders.where((order) {
      if (order.orderedAt == null || order.status == 'cancelled') return false;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        return orderDate.isAfter(yesterdayStart) && orderDate.isBefore(yesterdayEnd);
      } catch (e) {
        return false;
      }
    }).toList();
    
    final growthRate = _calculateGrowthRate(todayOrders, yesterdayOrders);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本日の売上',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${_formatNumber(totalSales)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('注文数', '$orderCount件'),
              _buildStatItem('平均単価', '¥${_formatNumber(averagePrice)}'),
              _buildStatItem('前日比', growthRate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyView(List<Order> todayOrders, List<Order> allOrders) {
    // 時間帯別の売上を集計
    final hourlyData = <int, int>{};
    for (final order in todayOrders) {
      if (order.orderedAt == null) continue;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        final hour = orderDate.hour;
        hourlyData[hour] = (hourlyData[hour] ?? 0) + (order.totalPrice ?? 0);
      } catch (e) {
        // エラーは無視
      }
    }

    // 商品別売上を集計
    final productSales = <String, Map<String, dynamic>>{};
    for (final order in todayOrders) {
      for (final detail in order.orderDetails) {
        final name = detail.productName ?? '不明';
        if (!productSales.containsKey(name)) {
          productSales[name] = {'quantity': 0, 'amount': 0};
        }
        productSales[name]!['quantity'] += detail.quantity ?? 0;
        productSales[name]!['amount'] += detail.subtotal ?? 0;
      }
    }

    // 売上順にソート
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => (b.value['amount'] as int).compareTo(a.value['amount'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '時間帯別売上',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          hourlyData.isEmpty
              ? _buildEmptyState('本日の注文データがありません')
              : _buildHourlyChart(hourlyData),
          const SizedBox(height: 24),
          const Text(
            '商品別売上',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          sortedProducts.isEmpty
              ? _buildEmptyState('商品データがありません')
              : _buildProductList(sortedProducts),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(List<Order> allOrders) {
    final weekOrders = _getWeekOrders(allOrders);
    
    // 曜日別の売上を集計
    final dailyData = <int, int>{};
    for (final order in weekOrders) {
      if (order.orderedAt == null) continue;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        final weekday = orderDate.weekday;
        dailyData[weekday] = (dailyData[weekday] ?? 0) + (order.totalPrice ?? 0);
      } catch (e) {
        // エラーは無視
      }
    }

    final totalSales = _calculateTotalSales(weekOrders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '週間売上推移',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          dailyData.isEmpty
              ? _buildEmptyState('今週の注文データがありません')
              : _buildWeeklyChart(dailyData),
          const SizedBox(height: 24),
          _buildSummaryCard2('週間売上合計', '¥${_formatNumber(totalSales)}', Colors.green),
          const SizedBox(height: 12),
          _buildSummaryCard2('注文件数', '${weekOrders.length}件', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(List<Order> allOrders) {
    final monthOrders = _getMonthOrders(allOrders);
    
    // 週別の売上を集計
    final weeklyData = <int, int>{};
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    for (final order in monthOrders) {
      if (order.orderedAt == null) continue;
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        final weekNumber = ((orderDate.difference(monthStart).inDays) ~/ 7) + 1;
        weeklyData[weekNumber] = (weeklyData[weekNumber] ?? 0) + (order.totalPrice ?? 0);
      } catch (e) {
        // エラーは無視
      }
    }

    final totalSales = _calculateTotalSales(monthOrders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月間売上推移（週別）',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          weeklyData.isEmpty
              ? _buildEmptyState('今月の注文データがありません')
              : _buildMonthlyChart(weeklyData),
          const SizedBox(height: 24),
          _buildSummaryCard2('月間売上合計', '¥${_formatNumber(totalSales)}', Colors.green),
          const SizedBox(height: 12),
          _buildSummaryCard2('注文件数', '${monthOrders.length}件', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildHourlyChart(Map<int, int> hourlyData) {
    final maxAmount = hourlyData.values.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxAmount == 0) return _buildEmptyState('売上データがありません');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(24, (index) {
            final hour = index;
            final amount = hourlyData[hour] ?? 0;
            if (amount == 0) return const SizedBox(width: 30);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildColumn('${hour}時', amount, maxAmount),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(Map<int, int> dailyData) {
    final maxAmount = dailyData.values.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxAmount == 0) return _buildEmptyState('売上データがありません');

    final weekdays = ['', '月', '火', '水', '木', '金', '土', '日'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final weekday = index + 1;
          final amount = dailyData[weekday] ?? 0;
          return _buildColumn(weekdays[weekday], amount, maxAmount);
        }),
      ),
    );
  }

  Widget _buildMonthlyChart(Map<int, int> weeklyData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: weeklyData.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final entries = weeklyData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
          if (index >= entries.length) return const SizedBox.shrink();
          
          final week = entries[index].key;
          final sales = entries[index].value;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '第$week週',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '¥${_formatNumber(sales)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumn(String label, int amount, double maxAmount) {
    final height = maxAmount > 0 ? (amount / maxAmount) * 150 : 0.0;

    return Column(
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProductList(List<MapEntry<String, Map<String, dynamic>>> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final entry = products[index];
          final name = entry.key;
          final quantity = entry.value['quantity'];
          final amount = entry.value['amount'];
          
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quantity個',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${_formatNumber(amount)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard2(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}