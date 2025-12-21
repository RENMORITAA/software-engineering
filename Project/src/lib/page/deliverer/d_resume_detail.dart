import 'package:flutter/material.dart';
import '../../component/component.dart';

class DResumeDetailPage extends StatelessWidget {
  const DResumeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '履歴書情報', backgroundColor: Color(0xFF2E7D32)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('基本情報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const GeneralForm(label: '氏名', initialValue: '佐藤 一郎'),
            const SizedBox(height: 16),
            const GeneralForm(label: '住所', initialValue: '東京都渋谷区...'),
            const SizedBox(height: 32),
            SingleButton(
              text: '編集する',
              onPressed: () {},
              color: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }
}
