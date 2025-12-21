import 'package:flutter/material.dart';
import '../../component/component.dart';

class SSalesPage extends StatelessWidget {
  const SSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: '売上管理', backgroundColor: Color(0xFFE65100)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('今月の売上', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            const Text('¥1,234,567', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
            const SizedBox(height: 32),
            SingleButton(
              text: '詳細レポート',
              onPressed: () {},
              color: const Color(0xFFE65100),
            ),
          ],
        ),
      ),
    );
  }
}
