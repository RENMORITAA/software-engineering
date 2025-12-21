import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../overlay/overlay.dart';

/// マイページ（共通）
class MyPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final VoidCallback onLogout;
  final VoidCallback onWithdraw;

  const MyPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onLogout,
    required this.onWithdraw,
  });

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _showLogout = false;
  bool _showWithdraw = false;

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
    return Stack(
      children: [
        Scaffold(
          appBar: const TitleAppBar(
            title: 'マイページ',
            showBackButton: false,
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
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : '?',
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _roleDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // メニュー一覧
                const SizedBox(height: 16),
                _buildMenuSection(
                  title: 'アカウント',
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      title: '会員情報',
                      onTap: () {
                        // TODO: 会員情報画面に遷移
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'パスワード変更',
                      onTap: () {
                        // TODO: パスワード変更画面に遷移
                      },
                    ),
                    if (widget.userRole == 'requester')
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: '住所管理',
                        onTap: () {
                          // TODO: 住所管理画面に遷移
                        },
                      ),
                    _MenuItem(
                      icon: Icons.account_balance_outlined,
                      title: '口座情報',
                      onTap: () {
                        // TODO: 口座情報画面に遷移
                      },
                    ),
                  ],
                ),
                _buildMenuSection(
                  title: '履歴',
                  items: [
                    if (widget.userRole == 'requester')
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: '注文履歴',
                        onTap: () {
                          // TODO: 注文履歴画面に遷移
                        },
                      ),
                    if (widget.userRole == 'requester')
                      _MenuItem(
                        icon: Icons.payment_outlined,
                        title: '支払い明細',
                        onTap: () {
                          // TODO: 支払い明細画面に遷移
                        },
                      ),
                    if (widget.userRole == 'deliverer')
                      _MenuItem(
                        icon: Icons.local_shipping_outlined,
                        title: '配達履歴',
                        onTap: () {
                          // TODO: 配達履歴画面に遷移
                        },
                      ),
                    if (widget.userRole == 'deliverer')
                      _MenuItem(
                        icon: Icons.attach_money,
                        title: '給与明細',
                        onTap: () {
                          // TODO: 給与明細画面に遷移
                        },
                      ),
                    if (widget.userRole == 'store')
                      _MenuItem(
                        icon: Icons.bar_chart_outlined,
                        title: '売上管理',
                        onTap: () {
                          // TODO: 売上管理画面に遷移
                        },
                      ),
                  ],
                ),
                _buildMenuSection(
                  title: 'その他',
                  items: [
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      title: '通知設定',
                      onTap: () {
                        // TODO: 通知設定画面に遷移
                      },
                    ),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      title: '利用規約',
                      onTap: () {
                        // TODO: 利用規約画面に遷移
                      },
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'ヘルプ・お問い合わせ',
                      onTap: () {
                        // TODO: ヘルプ画面に遷移
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ログアウト・退会
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _showLogout = true;
                            });
                          },
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
                        onPressed: () {
                          setState(() {
                            _showWithdraw = true;
                          });
                        },
                        child: Text(
                          '退会はこちら',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // ログアウト確認オーバーレイ
        if (_showLogout)
          LogoutOverlay(
            onConfirm: () {
              setState(() {
                _showLogout = false;
              });
              widget.onLogout();
            },
            onCancel: () {
              setState(() {
                _showLogout = false;
              });
            },
          ),
        // 退会確認オーバーレイ
        if (_showWithdraw)
          WithdrawOverlay(
            onConfirm: () {
              setState(() {
                _showWithdraw = false;
              });
              widget.onWithdraw();
            },
            onCancel: () {
              setState(() {
                _showWithdraw = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(item.title),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
