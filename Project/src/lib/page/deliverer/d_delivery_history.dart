import 'package:flutter/material.dart';

class DDeliveryDetailPage extends StatelessWidget {
  final int index;

  const DDeliveryDetailPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配達詳細'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '配達番号：$index',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('配達日：2025年12月${21 - index}日'),
            const SizedBox(height: 8),
            Text('店舗名：店舗${index + 1}'),
            const SizedBox(height: 8),
            Text('ステータス：配達完了'),
            const SizedBox(height: 8),
            Text('報酬：¥${500 + (index * 50)}'),
          ],
        ),
      ),
    );
  }
}