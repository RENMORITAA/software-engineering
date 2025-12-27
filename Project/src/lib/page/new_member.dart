import 'package:flutter/material.dart';
import '../../component/component.dart';
import '../../overlay/overlay.dart';
import '../../services/auth_service.dart';

/// 新規会員登録画面
class NewMemberPage extends StatefulWidget {
  const NewMemberPage({super.key});

  @override
  State<NewMemberPage> createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // 店舗用フィールド
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  final _businessHoursController = TextEditingController();

  // 配達員用フィールド
  String _selectedVehicleType = 'bicycle';

  String _selectedRole = 'requester';
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _showTerms = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storeDescriptionController.dispose();
    _businessHoursController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('利用規約に同意してください')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
        name: _nameController.text,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        // 店舗用
        storeName: _selectedRole == 'store' ? _storeNameController.text : null,
        storeAddress: _selectedRole == 'store' ? _storeAddressController.text : null,
        storeDescription: _selectedRole == 'store' ? _storeDescriptionController.text : null,
        businessHours: _selectedRole == 'store' ? _businessHoursController.text : null,
        // 配達員用
        vehicleType: _selectedRole == 'deliverer' ? _selectedVehicleType : null,
      );

      if (mounted) {
        // 登録成功後、ログイン画面に遷移
        Navigator.pushReplacementNamed(context, '/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('会員登録が完了しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登録に失敗しました: $e')),
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
    return Stack(
      children: [
        Scaffold(
          appBar: const TitleAppBar(
            title: '新規会員登録',
            showBackButton: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ロール選択
                    const Text(
                      '会員種別を選択',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRoleSelector(),
                    const SizedBox(height: 24),
                    // 基本情報
                    GeneralForm(
                      label: 'お名前',
                      hint: '山田 太郎',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline),
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'お名前を入力してください';
                        }
                        return null;
                      },
                    ),
                    GeneralForm(
                      label: 'メールアドレス',
                      hint: 'example@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'メールアドレスを入力してください';
                        }
                        if (!value.contains('@')) {
                          return '有効なメールアドレスを入力してください';
                        }
                        return null;
                      },
                    ),
                    GeneralForm(
                      label: '電話番号',
                      hint: '090-1234-5678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: (value) {
                        // 任意項目
                        return null;
                      },
                    ),
                    // 店舗用追加フィールド
                    if (_selectedRole == 'store') ...[
                      const SizedBox(height: 16),
                      const Text(
                        '店舗情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GeneralForm(
                        label: '店舗名',
                        hint: '〇〇レストラン',
                        controller: _storeNameController,
                        prefixIcon: const Icon(Icons.store_outlined),
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '店舗名を入力してください';
                          }
                          return null;
                        },
                      ),
                      GeneralForm(
                        label: '店舗住所',
                        hint: '東京都渋谷区...',
                        controller: _storeAddressController,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        required: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '店舗住所を入力してください';
                          }
                          return null;
                        },
                      ),
                      GeneralForm(
                        label: '店舗説明',
                        hint: '美味しい料理をお届けします',
                        controller: _storeDescriptionController,
                        prefixIcon: const Icon(Icons.description_outlined),
                        maxLines: 3,
                      ),
                      GeneralForm(
                        label: '営業時間',
                        hint: '10:00-22:00',
                        controller: _businessHoursController,
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                    ],
                    // 配達員用追加フィールド
                    if (_selectedRole == 'deliverer') ...[
                      const SizedBox(height: 16),
                      const Text(
                        '配達情報',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildVehicleTypeSelector(),
                    ],
                    PasswordInput(
                      controller: _passwordController,
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        if (value.length < 6) {
                          return 'パスワードは6文字以上で入力してください';
                        }
                        return null;
                      },
                    ),
                    PasswordInput(
                      label: 'パスワード（確認）',
                      hint: 'パスワードを再入力',
                      controller: _confirmPasswordController,
                      required: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを再入力してください';
                        }
                        if (value != _passwordController.text) {
                          return 'パスワードが一致しません';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // 利用規約同意
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showTerms = true;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                children: [
                                  const TextSpan(text: ''),
                                  TextSpan(
                                    text: '利用規約',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: 'に同意する'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 登録ボタン
                    SingleButton(
                      text: '登録する',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      enabled: _agreedToTerms,
                      icon: Icons.person_add,
                    ),
                    const SizedBox(height: 16),
                    // ログインへ戻る
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('すでにアカウントをお持ちの方はこちら'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 利用規約オーバーレイ
        if (_showTerms)
          RuleScreenOverlay(
            onClose: () {
              setState(() {
                _showTerms = false;
              });
            },
            showAgreeButton: true,
            onAgree: () {
              setState(() {
                _agreedToTerms = true;
                _showTerms = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildRoleOption(
            value: 'requester',
            icon: Icons.shopping_bag_outlined,
            title: '依頼者',
            subtitle: '商品を注文する',
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildRoleOption(
            value: 'deliverer',
            icon: Icons.delivery_dining_outlined,
            title: '配達員',
            subtitle: '商品を配達する',
          ),
          Divider(height: 1, color: Colors.grey[300]),
          _buildRoleOption(
            value: 'store',
            icon: Icons.store_outlined,
            title: '店舗',
            subtitle: '商品を販売する',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeSelector() {
    final vehicleTypes = [
      {'value': 'bicycle', 'icon': Icons.pedal_bike, 'label': '自転車'},
      {'value': 'motorcycle', 'icon': Icons.two_wheeler, 'label': 'バイク'},
      {'value': 'car', 'icon': Icons.directions_car, 'label': '車'},
      {'value': 'walk', 'icon': Icons.directions_walk, 'label': '徒歩'},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '配達手段',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicleTypes.map((type) {
              final isSelected = _selectedVehicleType == type['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVehicleType = type['value'] as String;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
