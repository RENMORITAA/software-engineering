import 'package:flutter/material.dart';

import 'component.dart';

/// 通知設定変更コンポーネント
class DNoticeChange extends StatefulWidget {
  const DNoticeChange({super.key});

  @override
  State<DNoticeChange> createState() => _DNoticeChangeState();
}

class _DNoticeChangeState extends State<DNoticeChange> {
  bool _pushNotification = true;
  bool _emailNotification = false;
  bool _smsNotification = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '通知設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          'プッシュ通知',
          'アプリからの重要なお知らせを受け取ります',
          _pushNotification,
          (value) {
            setState(() {
              _pushNotification = value;
            });
          },
        ),
        const Divider(),
        _buildSwitchTile(
          'メール通知',
          '登録メールアドレスにお知らせを送信します',
          _emailNotification,
          (value) {
            setState(() {
              _emailNotification = value;
            });
          },
        ),
        const Divider(),
        _buildSwitchTile(
          'SMS通知',
          '緊急時の連絡をSMSで受け取ります',
          _smsNotification,
          (value) {
            setState(() {
              _smsNotification = value;
            });
          },
        ),
        const SizedBox(height: 24),
        SingleButton(
          text: '設定を保存',
          onPressed: () {
            // TODO: 設定保存処理
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('設定を保存しました')),
            );
          },
          color: const Color(0xFF2E7D32),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2E7D32),
    );
  }
}
