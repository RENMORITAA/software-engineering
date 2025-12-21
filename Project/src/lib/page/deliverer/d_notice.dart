import 'package:flutter/material.dart';

import '../../component/component.dart';

/// 通知一覧画面
class DNoticePage extends StatelessWidget {
  const DNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '通知',
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info, color: Colors.blue),
            ),
            title: Text('重要なお知らせ ${index + 1}'),
            subtitle: const Text('システムメンテナンスのお知らせです。'),
            trailing: const Text(
              '10分前',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              // TODO: 通知詳細へ
            },
          );
        },
      ),
    );
  }
}
