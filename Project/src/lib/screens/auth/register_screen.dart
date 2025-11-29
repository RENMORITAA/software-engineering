import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 役割選択用
  String _selectedRole = '依頼者';
  final List<String> _roles = ['依頼者', '配達員', '店舗'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規会員登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('利用目的を選択してください',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 24),
            
            // 共通項目
            TextFormField(
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'パスワード（確認）'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // 役割ごとの固有項目（簡易表示）
            if (_selectedRole == '店舗')
               TextFormField(decoration: const InputDecoration(labelText: '店舗名')),
            if (_selectedRole == '配達員')
               TextFormField(decoration: const InputDecoration(labelText: '氏名')),
            
            const SizedBox(height: 32),
            CustomButton(
              text: '登録して次へ',
              onPressed: () {
                // 本人確認メール送信処理など
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('登録処理を実行します')),
                );
                Navigator.pop(context); // ログイン画面へ戻る
              },
            ),
          ],
        ),
      ),
    );
  }
}