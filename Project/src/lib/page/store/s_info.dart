import 'package:flutter/material.dart';

import '../../component/component.dart';

/// 店舗情報画面
class SInfoPage extends StatelessWidget {
  const SInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '店舗情報',
        backgroundColor: Color(0xFFE65100),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE65100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const GeneralForm(
              label: '店舗名',
              hint: '店舗名を入力',
              initialValue: 'テスト食堂',
            ),
            const SizedBox(height: 16),
            const GeneralForm(
              label: '電話番号',
              hint: '電話番号を入力',
              initialValue: '0887-12-3456',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const GeneralForm(
              label: '住所',
              hint: '住所を入力',
              initialValue: '高知県香美市土佐山田町1-1',
            ),
            const SizedBox(height: 16),
            const GeneralForm(
              label: '営業時間',
              hint: '営業時間を入力',
              initialValue: '10:00 - 22:00',
            ),
            const SizedBox(height: 16),
            const GeneralForm(
              label: '紹介文',
              hint: '店舗の紹介文を入力',
              initialValue: '美味しい定食を提供しています。',
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SingleButton(
              text: '保存する',
              onPressed: () {
                Navigator.pop(context);
              },
              color: const Color(0xFFE65100),
            ),
          ],
        ),
      ),
    );
  }
}
