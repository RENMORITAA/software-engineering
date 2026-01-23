import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../component/component.dart';
import '../../models/database_models.dart';
import '../../provider/order_provider.dart';

/// 依頼者用 支払い明細画面（実データ版）
/// システム提案書に基づき月末一括精算方式で実装
class CPaymentHistoryPage extends StatefulWidget {
  const CPaymentHistoryPage({super.key});

  @override
  State<CPaymentHistoryPage> createState() => _CPaymentHistoryPageState();
}

class _CPaymentHistoryPageState extends State<CPaymentHistoryPage> {
  final DateFormat _monthFormat = DateFormat('yyyy年MM月');
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');
  final NumberFormat _currencyFormat = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    // 注文履歴を取得（支払い計算のため）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchMyOrders();
    });
  }

  // 月ごとに注文を集計
  Map<String, List<Order>> _groupOrdersByMonth(List<Order> orders) {
    final Map<String, List<Order>> grouped = {};
    
    for (final order in orders) {
      // キャンセルされた注文は除外
      if (order.status == 'cancelled') continue;
      
      if (order.orderedAt == null) continue;
      
      try {
        final orderDate = DateTime.parse(order.orderedAt!);
        final monthKey = _monthFormat.format(orderDate);
        
        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }
        grouped[monthKey]!.add(order);
      } catch (e) {
        // 日付解析エラーは無視
        continue;
      }
    }
    
    return grouped;
  }

  // 月の合計金額を計算
  int _calculateMonthTotal(List<Order> orders) {
    return orders.fold(0, (sum, order) => sum + (order.totalPrice ?? 0));
  }

  // 支払いステータスを判定
  // 提案書: 月末一括精算、翌月初めに支払い
  String _determinePaymentStatus(String monthKey) {
    try {
      final now = DateTime.now();
      final currentMonth = _monthFormat.format(now);
      final monthDate = _monthFormat.parse(monthKey);
      
      // 今月 → 未確定（月末まで注文受付中）
      if (monthKey == currentMonth) {
        return 'unconfirmed';
      }
      
      // 先月 → 確定（月末締め、翌月初め支払い待ち）
      final lastMonth = DateTime(now.year, now.month - 1);
      if (monthDate.year == lastMonth.year && monthDate.month == lastMonth.month) {
        // 今日が翌月5日以降なら支払済みと見なす（仮定）
        if (now.day >= 5) {
          return 'paid';
        }
        return 'confirmed';
      }
      
      // それ以前 → 支払済み
      if (monthDate.isBefore(lastMonth)) {
        return 'paid';
      }
      
      return 'unconfirmed';
    } catch (e) {
      return 'unconfirmed';
    }
  }

  // 引落予定日を計算（翌月25日と仮定、提案書に基づく）
  String _calculateDueDate(String monthKey) {
    try {
      final monthDate = _monthFormat.parse(monthKey);
      // 翌月25日
      final dueDate = DateTime(monthDate.year, monthDate.month + 1, 25);
      return _dateFormat.format(dueDate);
    } catch (e) {
      return '未定';
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final allOrders = orderProvider.orders;
    
    // 月ごとにグループ化
    final groupedOrders = _groupOrdersByMonth(allOrders);
    
    // 月の降順でソート（新しい月が上）
    final sortedMonths = groupedOrders.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = _monthFormat.parse(a);
          final dateB = _monthFormat.parse(b);
          return dateB.compareTo(dateA); // 降順
        } catch (e) {
          return 0;
        }
      });

    return Scaffold(
      appBar: const TitleAppBar(
        title: '支払い明細',
        showBackButton: true,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedOrders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<OrderProvider>().fetchMyOrders();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedMonths.length,
                    itemBuilder: (context, index) {
                      final month = sortedMonths[index];
                      final orders = groupedOrders[month]!;
                      final totalAmount = _calculateMonthTotal(orders);
                      final status = _determinePaymentStatus(month);
                      final dueDate = _calculateDueDate(month);
                      
                      return _buildPaymentCard(
                        month: month,
                        orders: orders,
                        totalAmount: totalAmount,
                        status: status,
                        dueDate: dueDate,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildPaymentCard({
    required String month,
    required List<Order> orders,
    required int totalAmount,
    required String status,
    required String dueDate,
  }) {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(status),
            ],
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // 合計情報
            _buildRow('注文件数', '${orders.length}件'),
            const SizedBox(height: 8),
            _buildRow('合計金額', '¥${_currencyFormat.format(totalAmount)}', isPrice: true),
            const SizedBox(height: 8),
            _buildRow('引落予定日', dueDate),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // 注文明細
            const Text(
              '注文明細',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...orders.map((order) => _buildOrderDetailRow(order)),
            
            // システム提案書に基づく支払い方法の説明
            if (status == 'unconfirmed' || status == 'confirmed') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status == 'unconfirmed'
                            ? '月末締め後、翌月初めに登録済みの決済方法で自動引き落としされます'
                            : '登録済みの決済方法で引き落とし処理中です',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '注文 #${order.id}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatOrderDate(order.orderedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (order.orderDetails.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _summarizeOrderItems(order.orderDetails),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '¥${_currencyFormat.format(order.totalPrice ?? 0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrderDate(String? orderedAt) {
    if (orderedAt == null) return '日時不明';
    try {
      final date = DateTime.parse(orderedAt);
      return DateFormat('MM/dd HH:mm').format(date);
    } catch (e) {
      return '日時不明';
    }
  }

  String _summarizeOrderItems(List<OrderDetail> details) {
    if (details.isEmpty) return '';
    final items = details.map((d) => d.productName ?? '商品').take(2).join(', ');
    if (details.length > 2) {
      return '$items 他${details.length - 2}件';
    }
    return items;
  }

  Widget _buildStatusChip(String status) {
    String text;
    Color color;
    IconData icon;
    
    switch (status) {
      case 'paid':
        text = '支払済';
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'confirmed':
        text = '確定';
        color = Colors.blue;
        icon = Icons.pending_actions;
        break;
      default:
        text = '未確定';
        color = Colors.orange;
        icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrice ? 20 : 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            color: isPrice ? const Color(0xFF1A237E) : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '支払い明細はありません',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '注文すると明細が表示されます',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}