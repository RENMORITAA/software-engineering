import 'package:flutter/material.dart';

import '../../component/component.dart';

/// メニュー管理画面
class SMenuEditPage extends StatelessWidget {
  const SMenuEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'メニュー管理',
        showBackButton: false,
        backgroundColor: Color(0xFFE65100),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildMenuCard(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 新規メニュー追加
        },
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'メニュー名 ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥800',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: const Color(0xFFE65100),
                      ),
                      const Text('販売中'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: 編集画面へ
            },
          ),
        ],
      ),
    );
  }
}
