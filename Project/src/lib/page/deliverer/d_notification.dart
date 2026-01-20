import "package:flutter/material.dart";
import "../../component/component.dart";

/// 通知画面
class DNotification extends StatelessWidget {
  const DNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '通知',
        backgroundColor: Color(0xFFE65100),
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final bool isRead = index % 3 == 0; // ダミーデータ：3件に1件は既読
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isRead ? Colors.white : const Color(0xFFFFF3E0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[300] : const Color(0xFFE65100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(index),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                _getNotificationTitle(index),
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(_getNotificationMessage(index)),
                  const SizedBox(height: 4),
                  Text(
                    _getNotificationTime(index),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: !isRead
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE65100),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                // 通知をタップした時の処理
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('通知 ${index + 1} を開きました')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.shopping_bag;
      case 1:
        return Icons.local_shipping;
      case 2:
        return Icons.info_outline;
      case 3:
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTitle(int index) {
    switch (index % 4) {
      case 0:
        return '新しい注文';
      case 1:
        return '配達完了';
      case 2:
        return 'システムお知らせ';
      case 3:
        return 'キャンペーン情報';
      default:
        return '通知';
    }
  }

  String _getNotificationMessage(int index) {
    switch (index % 4) {
      case 0:
        return '新しい注文が入りました。確認してください。';
      case 1:
        return '注文番号 #${1000 + index} の配達が完了しました。';
      case 2:
        return 'システムメンテナンスのお知らせ';
      case 3:
        return '期間限定キャンペーン実施中！';
      default:
        return '通知メッセージ';
    }
  }

  String _getNotificationTime(int index) {
    final now = DateTime.now();
    final time = now.subtract(Duration(hours: index));
    
    if (index == 0) return 'たった今';
    if (index < 24) return '${index}時間前';
    return '${index ~/ 24}日前';
  }
}