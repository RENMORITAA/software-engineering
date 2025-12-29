import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // FastAPI の OAuth2 形式でログイン（form-data）
      final response = await _apiService.post(
        '/auth/login',
        {
          'username': _emailController.text,
          'password': _passwordController.text,
        },
        isFormData: true,
      );

      // トークンを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['access_token']);

      // ユーザー情報を取得してロールに応じて画面遷移
      final userInfo = await _apiService.get('/auth/me/profile');
      final role = userInfo['role'] as String;

      if (!mounted) return;

      switch (role) {
        case 'requester':
          Navigator.pushReplacementNamed(context, AppRoutes.requestorHome);
          break;
        case 'deliverer':
          Navigator.pushReplacementNamed(context, AppRoutes.delivererHome);
          break;
        case 'store':
          Navigator.pushReplacementNamed(context, AppRoutes.storeHome);
          break;
        case 'admin':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('管理者画面は準備中です')),
          );
          break;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ログインに失敗しました。メールアドレスまたはパスワードを確認してください。';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('ログイン'),
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text('新規会員登録はこちら'),
                ),
                
                // 開発用テストアカウント情報
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'テストアカウント（開発用）',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTestAccountInfo('依頼者', 'user1@test.com', 'password'),
                _buildTestAccountInfo('店舗', 'store1@test.com', 'password'),
                _buildTestAccountInfo('配達員', 'deliverer1@test.com', 'password'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestAccountInfo(String role, String email, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text('$role:', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _emailController.text = email;
                _passwordController.text = password;
              },
              child: Text(
                email,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}