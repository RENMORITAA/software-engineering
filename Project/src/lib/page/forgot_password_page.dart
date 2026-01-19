import 'package:flutter/material.dart';
import '../component/component.dart'; // 既存のコンポーネントを使用

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: AuthServiceにパスワードリセットメソッドを実装して呼び出す
      // await _authService.sendPasswordResetEmail(_emailController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('パスワード再設定用のメールを送信しました。')),
        );
        Navigator.pop(context); // ログイン画面に戻る
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('パスワードの再設定')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ご登録済みのメールアドレスを入力してください。\nパスワード再設定用のリンクをお送りします。',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              GeneralForm(
                label: 'メールアドレス',
                hint: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'メールアドレスを入力してください';
                  if (!value.contains('@')) return '有効なメールアドレスを入力してください';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SingleButton(
                text: '送信する',
                onPressed: _handleResetPassword,
                isLoading: _isLoading,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}