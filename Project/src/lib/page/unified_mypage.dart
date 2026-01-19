import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import '../component/component.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';

/// 統合マイページ＆設定画面
/// 全ロール（依頼者・配達員・店舗）共通で使用可能
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

class _UnifiedMyPageState extends State<UnifiedMyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isEditing = false;              // プロフィール編集モード
  bool _isChangingPassword = false;     // パスワード変更中
  
  bool _isCurrentPwVisible = false;    // 現在のパスワード表示フラグ
  bool _isNewPwVisible = false;        // 新しいパスワード表示フラグ
  bool _isConfirmPwVisible = false;    // 確認用パスワード表示フラグ

  // パスワード用コントローラー
  final TextEditingController _currentPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // 追加：使い終わったらメモリを解放する
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  String get _roleDisplayName {
    switch (widget.userRole) {
      case 'requester':
        return '依頼者';
      case 'deliverer':
        return '配達員';
      case 'store':
        return '店舗';
      case 'admin':
        return '管理者';
      default:
        return widget.userRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: const Text('保存'),
                )
              : TextButton(
                  onPressed: () {
                    setState(() => _isEditing = true);
                  },
                  child: const Text('編集'),
                ),
        ],
      ),
      body: Column(
        children: [
          // タブ
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'プロフィール'),
                Tab(text: '設定'),
                Tab(text: 'サポート'),
              ],
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
            ),
          ),
          // タブ内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildSettingsTab(),
                _buildSupportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (_isEditing) ...[
            _buildEditForm(),
            const SizedBox(height: 24),
          ],
          // 基本情報カード
          _buildCard(
            title: '基本情報',
            children: [
              _buildInfoRow('ユーザータイプ', _roleDisplayName),
              _buildInfoRow('メールアドレス', widget.userEmail),
              if (widget.additionalInfo != null)
                ...widget.additionalInfo!.entries.map(
                  (e) => _buildInfoRow(e.key, e.value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // セキュリティ
          _buildCard(
            title: 'セキュリティ',
            children: [
              _buildSettingTile(
                Icons.lock_outline,
                'パスワード変更',
                onTap: () => _showPasswordChangeDialog(),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.verified_user_outlined,
                '2要素認証',
                trailing: Switch(
                  value: false,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ロール固有設定
          if (widget.roleSpecificSettings != null &&
              widget.roleSpecificSettings!.isNotEmpty) ...[
            _buildCard(
              title: 'ロール設定',
              children: List.generate(
                widget.roleSpecificSettings!.length,
                (index) {
                  final setting = widget.roleSpecificSettings![index];
                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 1),
                      _buildSettingTile(
                        setting['icon'] ?? Icons.settings,
                        setting['title'] ?? '',
                        onTap: setting['onTap'],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            title: '通知設定',
            children: [
              _buildToggleSetting('注文通知', true),
              const Divider(height: 1),
              _buildToggleSetting('配達更新通知', true),
              const Divider(height: 1),
              _buildToggleSetting('プロモーション', false),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'プライバシー',
            children: [
              _buildSettingTile(
                Icons.visibility_outlined,
                'プロフィール表示',
                trailing: const Text('公開'),
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.location_on_outlined,
                '位置情報共有',
                trailing: const Text('許可'),
                onTap: () {},
              ),
            ],
          ),
          //言語設定等の設定を消しました

          const SizedBox(height: 16),
          _buildCard(
            title: 'その他',
            children: [
              _buildSettingTile(
                Icons.info_outlined,
                'アプリバージョン',
                trailing: const Text('1.0.0'),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.description_outlined,
                '利用規約',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.privacy_tip_outlined,
                'プライバシーポリシー',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            title: 'よくある質問',
            children: [
              _buildSupportTile(
                'サービスについて',
                Icons.help_outline,
              ),
              const Divider(height: 1),
              _buildSupportTile(
                '支払い・手数料',
                Icons.payment_outlined,
              ),
              const Divider(height: 1),
              _buildSupportTile(
                'トラブルシューティング',
                Icons.troubleshoot_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'サポート',
            children: [
              _buildSettingTile(
                Icons.mail_outline,
                'お問い合わせ',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showContactDialog(),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.phone_outlined,
                'カスタマーサポート',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.bug_report_outlined,
                '不具合報告',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'アカウント',
            children: [
              _buildSettingTile(
                Icons.logout,
                'ログアウト',
                trailing: const Icon(Icons.chevron_right),
                textColor: Colors.orange,
                onTap: () => _showLogoutDialog(),
              ),
              const Divider(height: 1),
              _buildSettingTile(
                Icons.delete_outline,
                '退会',
                trailing: const Icon(Icons.chevron_right),
                textColor: Colors.red,
                onTap: () => _showWithdrawDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              widget.userName.isNotEmpty
                  ? widget.userName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.userEmail,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _roleDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'プロフィール編集',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'ユーザー名',
            hintText: widget.userName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'メールアドレス',
            hintText: widget.userEmail,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.additionalInfo != null)
          ...widget.additionalInfo!.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: e.key,
                  hintText: e.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildToggleSetting(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: (_) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildSupportTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) { // ← ここに builder が必要です
          return AlertDialog( // ← ここで AlertDialog を返します
            title: const Text('パスワード変更'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 現在のパスワード
                TextField(
                  controller: _currentPwController,
                  decoration: InputDecoration(
                    labelText: '現在のパスワード',
                    suffixIcon: IconButton(
                      icon: Icon(_isCurrentPwVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => _isCurrentPwVisible = !_isCurrentPwVisible),
                    ),
                  ),
                  obscureText: !_isCurrentPwVisible, // 変数と連動
                ),
                // 2. 新しいパスワード
                TextField(
                  controller: _newPwController,
                  decoration: InputDecoration(
                    labelText: '新しいパスワード',
                    suffixIcon: IconButton(
                      icon: Icon(_isNewPwVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => _isNewPwVisible = !_isNewPwVisible),
                    ),
                  ),
                  obscureText: !_isNewPwVisible, // 変数と連動
                ),
                // 3. 確認用パスワード
                TextField(
                  controller: _confirmPwController,
                  decoration: InputDecoration(
                    labelText: '新しいパスワード（確認）',
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPwVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDialogState(() => _isConfirmPwVisible = !_isConfirmPwVisible),
                    ),
                  ),
                  obscureText: !_isConfirmPwVisible, // 変数と連動
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // 1. 親画面の変数をリセット（目のマークを非表示状態に戻す）
                  setState(() {
                    _isCurrentPwVisible = false;
                    _isNewPwVisible = false;
                    _isConfirmPwVisible = false;
                  });

                  // 2. 入力コントローラーをクリア（文字を消す）
                  _currentPwController.clear();
                  _newPwController.clear();
                  _confirmPwController.clear();

                  // 3. ダイアログを閉じる
                  Navigator.pop(context);
                },
                child: const Text('キャンセル'),
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
                child: _isChangingPassword
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('変更'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('お問い合わせ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'お問い合わせ内容',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('お問い合わせを送信しました')),
              );
              Navigator.pop(context);
            },
            child: const Text('送信'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('本当にログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退会'),
        content: const Text(
          '退会すると、すべてのアカウント情報が削除されます。\nこの操作は取り消せません。本当に退会しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onWithdraw();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退会'),
          ),
        ],
      ),
    );
  }
}
