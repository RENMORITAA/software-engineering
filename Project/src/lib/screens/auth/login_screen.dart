import 'package:flutter/material.dart';
import '../../config/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 開発用：ログインタイプを選択するドロップダウン用
  String _selectedRole = 'Requestor'; 
  final List<String> _roles = ['Requestor', 'Deliverer', 'Store', 'Admin'];

  void _login() {
    // TODO: ここでFirebase AuthやバックエンドAPIを使用した認証処理を行う
    // 現在はモックとして、選択されたロールに応じて画面遷移する
    
    switch (_selectedRole) {
      case 'Requestor':
        Navigator.pushReplacementNamed(context, AppRoutes.requestorHome);
        break;
      case 'Deliverer':
        Navigator.pushReplacementNamed(context, AppRoutes.delivererHome);
        break;
      case 'Store':
        Navigator.pushReplacementNamed(context, AppRoutes.storeHome);
        break;
      case 'Admin':
        // Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin screen not implemented yet')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Stellar Delivery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 48),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'パスワード',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              // 開発用ロール選択
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'ログインする役割 (開発用)'),
                items: _roles.map((String role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _login,
                child: const Text('ログイン'),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // 新規登録画面へ
                },
                child: const Text('新規会員登録はこちら'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}