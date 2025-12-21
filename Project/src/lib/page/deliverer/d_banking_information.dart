import 'package:flutter/material.dart';
import '../../component/component.dart';

class DBankingInformationPage extends StatelessWidget {
  const DBankingInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '口座情報', backgroundColor: Color(0xFF2E7D32)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GeneralForm(label: '銀行名', initialValue: 'テスト銀行'),
            const SizedBox(height: 16),
            const GeneralForm(label: '支店名', initialValue: '本店'),
            const SizedBox(height: 16),
            const GeneralForm(label: '口座番号', initialValue: '1234567'),
            const SizedBox(height: 16),
            const GeneralForm(label: '口座名義', initialValue: 'サトウ イチロウ'),
            const SizedBox(height: 32),
            SingleButton(
              text: '変更する',
              onPressed: () {},
              color: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }
}
