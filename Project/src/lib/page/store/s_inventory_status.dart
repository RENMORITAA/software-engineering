import 'package:flutter/material.dart';

import '../../component/component.dart';

/// 在庫管理画面
class SInventoryStatusPage extends StatelessWidget {
  const SInventoryStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '在庫管理',
        backgroundColor: Color(0xFFE65100),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('食材アイテム ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {},
                ),
                const Text(
                  '10',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
