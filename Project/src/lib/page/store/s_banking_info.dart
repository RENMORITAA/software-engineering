import 'package:flutter/material.dart';
import '../../component/component.dart';

class SBankingInfoPage extends StatelessWidget {
  const SBankingInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '蜿｣蠎ｧ諠・ｱ', backgroundColor: Color(0xFFE65100)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GeneralForm(label: '驫陦悟錐', initialValue: '繝・せ繝磯橿陦・),
            const SizedBox(height: 16),
            const GeneralForm(label: '謾ｯ蠎怜錐', initialValue: '譛ｬ蠎・),
            const SizedBox(height: 16),
            const GeneralForm(label: '蜿｣蠎ｧ逡ｪ蜿ｷ', initialValue: '7654321'),
            const SizedBox(height: 16),
            const GeneralForm(label: '蜿｣蠎ｧ蜷咲ｾｩ', initialValue: '繝・せ繝医す繝ｧ繧ｯ繝峨え'),
            const SizedBox(height: 32),
            SingleButton(
              text: '螟画峩縺吶ｋ',
              onPressed: () {},
              color: const Color(0xFFE65100),
            ),
          ],
        ),
      ),
    );
  }
}
