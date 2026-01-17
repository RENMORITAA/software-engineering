import "package:flutter/material.dart";

import "../../component/component.dart";

/// メニュー編集（ダミー）
class SMenuEditPage extends StatelessWidget {
  const SMenuEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'メニュー編集',
        showBackButton: false,
        backgroundColor: Color(0xFFE65100),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => _buildMenuCard(index),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuCard(int index) {
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
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('メニュー${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('¥800', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Switch(value: true, onChanged: (_) {}, activeColor: const Color(0xFFE65100)),
                      const Text('販売中'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
    );
  }
}
