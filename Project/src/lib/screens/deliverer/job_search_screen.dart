import 'package:flutter/material.dart';

class JobSearchScreen extends StatelessWidget {
  const JobSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('求人を探す')),
      body: Column(
        children: [
          // 検索フィルター
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'エリアで検索',
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('店舗 B からの配達依頼'),
                    subtitle: const Text('距離: 2.5km • 報酬: ¥600'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // 詳細確認・受注画面へ
                      },
                      child: const Text('詳細'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}