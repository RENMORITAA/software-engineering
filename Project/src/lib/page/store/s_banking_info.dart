import 'package:flutter/material.dart';
import '../../component/component.dart';

class SBankingInfoPage extends StatelessWidget {
  const SBankingInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '口座情報', backgroundColor: Color(0xFFE65100)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GeneralForm(label: '銀行名', initialValue: 'テスト銀行'),
            const SizedBox(height: 16),
            const GeneralForm(label: '支店名', initialValue: '本店'),
            const SizedBox(height: 16),
            const GeneralForm(label: '口座番号', initialValue: '7654321'),
            const SizedBox(height: 16),
            const GeneralForm(label: '口座名義', initialValue: 'テストショクドウ'),
            const SizedBox(height: 32),
            SingleButton(
              text: '変更する',
              onPressed: () {},
              color: const Color(0xFFE65100),
            ),
          ],
        ),
      ),
    );
  }
}
