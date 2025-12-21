import 'package:flutter/material.dart';
import '../../component/component.dart';

class DPayslipPage extends StatelessWidget {
  const DPayslipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '給与明細', backgroundColor: Color(0xFF2E7D32)),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('2025年${12 - index}月分'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 詳細表示
            },
          );
        },
      ),
    );
  }
}
