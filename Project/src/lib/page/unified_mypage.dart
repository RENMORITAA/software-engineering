import 'package:flutter/material.dart';
import '../component/component.dart';
import '../overlay/overlay.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'user_detail_page.dart';
import 'package:provider/provider.dart';
import '../provider/provider.dart';
import 'help_contact_page.dart';
import 'requester/c_address_edit.dart';
import 'banking_info_page.dart';

/// 統合マイページ（メニュー一覧レイアウト版）
class UnifiedMyPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final String accessToken;
  final Map<String, String>? additionalInfo;
  final VoidCallback onLogout;
  final VoidCallback onWithdraw;
  final List<Map<String, dynamic>>? roleSpecificSettings;

  const UnifiedMyPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.accessToken,
    this.additionalInfo,
    required this.onLogout,
    required this.onWithdraw,
    this.roleSpecificSettings,
  });

  @override
  State<UnifiedMyPage> createState() => _UnifiedMyPageState();
}

class _UnifiedMyPageState extends State<UnifiedMyPage> {
  bool _showLogout = false;
  bool _showWithdraw = false;
  bool _isEditing = false;
  bool _showTerms = false;

  // 編集用コントローラー
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // --- 追加：パスワード変更用 ---
  final TextEditingController _currentPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  bool _isCurrentPwVisible = false;
  bool _isNewPwVisible = false;
  bool _isConfirmPwVisible = false;
  bool _isChangingPassword = false;
  // --- ここまで ---

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // --- 追加：コントローラーの破棄 ---
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    // --- ここまで ---
    super.dispose();
  }

  String get _roleDisplayName {
    switch (widget.userRole) {
      case 'requester': return '依頼者';
      case 'deliverer': return '配達員';
      case 'store': return '店舗';
      case 'admin': return '管理者';
      default: return widget.userRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: TitleAppBar(
            title: 'マイページ',
            showBackButton: false,
            actions: [
              _isEditing
                  ? TextButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('変更を保存しました')),
                        );
                      },
                      child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    )
                  : TextButton(
                      onPressed: () => setState(() => _isEditing = true),
                      child: const Text('編集'),
                    ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // プロフィールヘッダー
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.userName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _roleDisplayName,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (_isEditing) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildEditForm(),
                  ),
                  const SizedBox(height: 24),
                ],

                _buildMenuSection(
                  title: 'アカウント',
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: '会員情報',
                      // unified_mypage.dart の「会員情報」リストタイルの onTap 部分
                        onTap: () {
                        // Providerを取得
                        final userProvider = Provider.of<UserRoleProvider>(context, listen: false);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(
                              // userProvider.userName と userProvider.userEmail に修正
                              userName: userProvider.userName ?? '名前未設定',
                              userEmail: userProvider.userEmail ?? '',
                              // userRole は文字列で渡す必要があるため roleToString() を使用
                              userRole: userProvider.roleToString(), 
                              additionalInfo: {
                                'phone_number': userProvider.phoneNumber,
                                'vehicle_type': userProvider.vehicleType,
                                'store_name': userProvider.storeName,
                                'store_address': userProvider.storeAddress,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'パスワード変更',
                      onTap: () => _showPasswordChangeDialog(),
                    ),
                    if (widget.userRole == 'requester')
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: '住所管理',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CAddressEditPage(),
                            ),
                          );
                        },
                      ),
                    _MenuItem(
                      icon: Icons.account_balance_outlined,
                      title: '口座情報',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // 修正：widget.userRole を引数として渡す
                            builder: (context) => BankingInfoPage(role: widget.userRole),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                _buildMenuSection(
                  title: '履歴',
                  items: [
                    if (widget.userRole == 'requester') ...[
                      _MenuItem(icon: Icons.receipt_long_outlined, title: '注文履歴', onTap: () {}),
                      _MenuItem(icon: Icons.payments_outlined, title: '支払い明細', onTap: () {}),
                    ],
                    if (widget.userRole == 'deliverer') ...[
                      _MenuItem(icon: Icons.local_shipping_outlined, title: '配達履歴', onTap: () {}),
                      _MenuItem(icon: Icons.payments_outlined, title: '給与明細', onTap: () {}),
                    ],
                    if (widget.userRole == 'store') ...[
                      _MenuItem(icon: Icons.bar_chart_outlined, title: '売上管理', onTap: () {}),
                    ],
                  ],
                ),

                _buildMenuSection(
                  title: 'その他',
                  items: [
                    //_MenuItem(icon: Icons.notifications_outlined, title: '通知設定', onTap: () {}),
                    _MenuItem(
                      icon: Icons.description_outlined, 
                      title: '利用規約', 
                      onTap: () => setState(() => _showTerms = true),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline, 
                      title: 'ヘルプ・お問い合わせ', 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  HelpContactPage()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _showLogout = true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('ログアウト'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _showWithdraw = true),
                        child: Text('退会はこちら', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        if (_showLogout)
          LogoutOverlay(
            onConfirm: () {
              setState(() => _showLogout = false);
              widget.onLogout();
            },
            onCancel: () => setState(() => _showLogout = false),
          ),

        if (_showWithdraw)
          WithdrawOverlay(
            onConfirm: () {
              setState(() => _showWithdraw = false);
              widget.onWithdraw();
            },
            onCancel: () => setState(() => _showWithdraw = false),
          ),

        if (_showTerms)
          RuleScreenOverlay(
            onClose: () => setState(() => _showTerms = false),
            showAgreeButton: false, 
            onAgree: () {}, 
          ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('プロフィール編集', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'ユーザー名', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'メールアドレス', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<_MenuItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600])),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: Theme.of(context).primaryColor),
                    title: Text(item.title),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 56, color: Colors.grey[200]),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- パスワード変更ダイアログ（デザイン修正版） ---
  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Center(
              child: Text('パスワード変更', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildDialogTextField(
                  controller: _currentPwController,
                  label: '現在のパスワード',
                  visible: _isCurrentPwVisible,
                  onToggle: () => setDialogState(() => _isCurrentPwVisible = !_isCurrentPwVisible),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: _newPwController,
                  label: '新しいパスワード',
                  visible: _isNewPwVisible,
                  onToggle: () => setDialogState(() => _isNewPwVisible = !_isNewPwVisible),
                ),
                const SizedBox(height: 16),
                _buildDialogTextField(
                  controller: _confirmPwController,
                  label: 'パスワード確認',
                  visible: _isConfirmPwVisible,
                  onToggle: () => setDialogState(() => _isConfirmPwVisible = !_isConfirmPwVisible),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            actions: [
              TextButton(
                onPressed: () {
                  // --- キャンセル時に全てリセット ---
                  _resetPasswordFields();
                  Navigator.pop(context);
                },
                child: const Text('キャンセル', style: TextStyle(color: Color(0xFF1A237E))),
              ),
              ElevatedButton(
                onPressed: _isChangingPassword
                    ? null
                    : () async {
                        if (_newPwController.text != _confirmPwController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('新しいパスワードが一致しません')),
                          );
                          return;
                        }

                        setDialogState(() => _isChangingPassword = true);

                        try {
                          final authService = AuthService();
                          final token = await authService.getToken();

                          final response = await http.post(
                            Uri.parse('http://localhost:8000/auth/change-password'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode({
                              'current_password': _currentPwController.text,
                              'new_password': _newPwController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            if (mounted) {
                              // --- 成功時も全てリセットしてから閉じる ---
                              _resetPasswordFields();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('パスワードを変更しました')),
                              );
                            }
                          } else {
                            throw Exception('変更に失敗しました');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('エラー：パスワードを変更できませんでした')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setDialogState(() => _isChangingPassword = false);
                            setState(() => _isChangingPassword = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isChangingPassword
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('変更'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 状態をデフォルトに戻す共通メソッド ---
  void _resetPasswordFields() {
    setState(() {
      // 入力内容をクリア
      _currentPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      // 表示状態（目のアイコン）を非表示に戻す
      _isCurrentPwVisible = false;
      _isNewPwVisible = false;
      _isConfirmPwVisible = false;
    });
  }

  // ダイアログ用テキストフィールドの補助ウィジェット
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.title, required this.onTap});
}