import 'package:flutter/material.dart';
import '../../component/component.dart';

/// 配達履歴画面
class DDeliveryHistoryPage extends StatelessWidget {
  const DDeliveryHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '配達履歴',
        showBackButton: false,
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildHistoryCard(context, index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, int index) {
    final date = '2025年12月${21 - index}日';
    final storeName = '店舗${index + 1}';
    final price = 500 + (index * 50);

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
                const Icon(Icons.store, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(storeName),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                const Text('配達完了'),
              ],
            ),
          ],
        ),
        trailing: Text(
          '¥$price',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        onTap: () {
          // 詳細画面へ遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DDeliveryHistoryDetailPage(
                date: date,
                storeName: storeName,
                price: price,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 配達履歴詳細画面
class DDeliveryHistoryDetailPage extends StatelessWidget {
  final String date;
  final String storeName;
  final int price;

  const DDeliveryHistoryDetailPage({
    super.key,
    required this.date,
    required this.storeName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
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
            const Center(
              child: Icon(Icons.check_circle, size: 64, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '配達完了',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            _buildDetailRow('配達日', date),
            _buildDetailRow('店舗名', storeName),
            _buildDetailRow('報酬合計', '¥$price', isBold: true),
            _buildDetailRow('配達ID', 'DEL-2025-00$price'), // ダミーID
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              '配達先情報',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('東京都渋谷区道玄坂1-2-3\nサンプルビル 405号室'),
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
}