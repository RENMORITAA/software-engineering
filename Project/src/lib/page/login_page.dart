import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../component/component.dart';
import '../../services/auth_service.dart';
import '../../provider/provider.dart';
import '../../config/routes.dart';

/// ログイン画面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        final user = await _authService.getCurrentUser();
        final role = user['role'] as String?;
        final userId = user['id'];
        final email = user['email'];
        
        // ユーザー惁E��をAuthServiceに保存（永続化�E�E
        await _authService.saveUserInfo(user);
        
        // プロフィール惁E��を取征E
        String? userName;
        String? phoneNumber;
        String? storeName;
        String? storeAddress;
        String? vehicleType;
        
        try {
          if (role == 'requester') {
            final profile = await _authService.getRequesterProfile();
            userName = profile['name'];
            phoneNumber = profile['phone_number'];
          } else if (role == 'deliverer') {
            final profile = await _authService.getDelivererProfile();
            userName = profile['name'];
            phoneNumber = profile['phone_number'];
            vehicleType = profile['vehicle_type'];
          } else if (role == 'store') {
            final profile = await _authService.getStoreProfile();
            storeName = profile['store_name'];
            storeAddress = profile['address'];
            phoneNumber = profile['phone_number'];
            userName = storeName; // 店�Eの場合�E店名をユーザー名として使用
          }
        } catch (e) {
          // プロフィール取得に失敗しても続衁E
          debugPrint('プロフィール取得エラー: $e');
        }
        
        // Providerにユーザー惁E��を保孁E
        if (mounted) {
          context.read<UserRoleProvider>().login(
            userId: userId,
            email: email,
            role: role ?? 'requester',
            name: userName,
            phoneNumber: phoneNumber,
            storeName: storeName,
            storeAddress: storeAddress,
            vehicleType: vehicleType,
          );
        }
        
        if (mounted) {
          // ロールに応じた�Eーム画面へ遷移
          String targetRoute;
          switch (role) {
            case 'deliverer':
              targetRoute = AppRoutes.delivererHome;
              break;
            case 'store':
              targetRoute = AppRoutes.storeHome;
              break;
            default:
              targetRoute = AppRoutes.requestorHome;
          }
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログインに失敗しました: $e')),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // ロゴ
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.star,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Stellar Delivery',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '香美市特化型配達サービス',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // メールアドレス
                GeneralForm(
                  label: 'メールアドレス',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを�E力してください';
                    }
                    if (!value.contains('@')) {
                      return '有効なメールアドレスを�E力してください';
                    }
                    return null;
                  },
                ),
                // パスワーチE
                PasswordInput(
                  controller: _passwordController,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    if (value.length < 6) {
                      return 'パスワード�E6斁E��以上で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // パスワードを忘れた場吁E
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: パスワードリセチE��画面に遷移
                    },
                    child: Text(
                      'パスワードをお忘れの方',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // ログインボタン
                SingleButton(
                  text: 'ログイン',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  icon: Icons.login,
                ),
                const SizedBox(height: 24),
                // 区刁E��緁E
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'また�E',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),
                // 新規登録ボタン
                SingleButton(
                  text: '新規会員登録',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  isOutlined: true,
                  icon: Icons.person_add_outlined,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
