import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 配達員用 給与明細画面
class DPaymentHistoryPage extends StatelessWidget {
  const DPaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // サンプルデータ
    final List<Map<String, dynamic>> earnings = [
      {'month': '2026年01月', 'amount': 125800, 'status': 'unconfirmed', 'payDate': '2026/02/15', 'count': 152},
      {'month': '2025年12月', 'amount': 142450, 'status': 'confirmed', 'payDate': '2026/01/15', 'count': 180},
      {'month': '2025年11月', 'amount': 118900, 'status': 'paid', 'payDate': '2025/12/15', 'count': 145},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('給与明細', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: earnings.isEmpty
          ? const Center(child: Text('給与明細はありません', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: earnings.length,
              itemBuilder: (context, index) => _buildEarningCard(earnings[index]),
            ),
    );
  }

  Widget _buildEarningCard(Map<String, dynamic> data) {
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
            _buildRow('配達件数', '${data['count']} 件'),
            const SizedBox(height: 8),
            _buildRow('振込予定日', data['payDate']),
            const SizedBox(height: 8),
            _buildRow('合計報酬', '¥${NumberFormat("#,###").format(data['amount'])}', isPrice: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    String text;
    Color color;
    switch (status) {
      case 'paid': text = '振込済'; color = Colors.green; break;
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
          color: isPrice ? const Color(0xFF1A237E) : Colors.black,
        )),
      ],
    );
  }
}