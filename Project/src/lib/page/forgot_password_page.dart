import 'package:flutter/material.dart';
import '../component/component.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  // 1. ここで定義が必要です
  final _authService = AuthService(); 
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. _authServiceが使えるようになります
      await _authService.sendPasswordResetEmail(_emailController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('パスワード再設定用のメールを送信しました。'),
            backgroundColor: Colors.green, // 正しい位置に配置
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('送信に失敗しました: $e'),
            backgroundColor: Colors.red, // 正しい位置に配置
          ),
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
      appBar: AppBar(title: const Text('仮パスワード発行')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '登録済みのメールアドレスを入力してください。\n仮パスワードを発行し、お送りします。',
                  style: TextStyle(color: Colors.grey),
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
      ),
    );
  }
}