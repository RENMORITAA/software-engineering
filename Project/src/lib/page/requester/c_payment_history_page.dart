import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 依頼者用 支払い明細画面
class CPaymentHistoryPage extends StatelessWidget {
  // コンストラクタ名をクラス名と一致させる
  const CPaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // サンプルデータ（実際はProvider等から取得）
    final List<Map<String, dynamic>> payments = [
      {'month': '2026年01月', 'amount': 15800, 'status': 'unconfirmed', 'dueDate': '2026/02/25'},
      {'month': '2025年12月', 'amount': 12450, 'status': 'confirmed', 'dueDate': '2026/01/25'},
      {'month': '2025年11月', 'amount': 18900, 'status': 'paid', 'dueDate': '2025/12/25'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('支払い明細', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E), // マイページと統一した紺色
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: payments.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
            ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['month'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildStatusChip(data['status']),
              ],
            ),
            const Divider(height: 32),
            _buildRow('合計金額', '¥${NumberFormat("#,###").format(data['amount'])}', isPrice: true),
            const SizedBox(height: 8),
            _buildRow('引落予定日', data['dueDate']),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String text;
    Color color;
    switch (status) {
      case 'paid': text = '支払済'; color = Colors.green; break;
      case 'confirmed': text = '確定'; color = Colors.blue; break;
      default: text = '未確定'; color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(
          fontSize: isPrice ? 20 : 14,
          fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('支払い明細はありません', style: TextStyle(color: Colors.grey)));
  }
}