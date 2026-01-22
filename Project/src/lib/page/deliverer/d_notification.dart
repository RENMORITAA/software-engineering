import "package:flutter/material.dart";
import "../../component/component.dart";

/// 通知画面
class DNotification extends StatefulWidget {
  const DNotification({super.key});

  @override
  State<DNotification> createState() => _DNotificationState();
}

class _DNotificationState extends State<DNotification> {
  final List<bool> _readStatus = List.generate(10, (index) => index % 3 == 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '通知',
        backgroundColor: Color(0xFF2E7D32),
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final bool isRead = _readStatus[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isRead ? Colors.white : const Color(0xFFE8F5E9),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[300] : const Color(0xFF2E7D32),
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
                  Text(
                    _getNotificationMessage(index),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                // 既読にする
                setState(() {
                  _readStatus[index] = true;
                });
                
                // 詳細画面を表示
                _showNotificationDetail(context, index);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ハンドルバー
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // アイコンとタイトル
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getNotificationIcon(index),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getNotificationTitle(index),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getNotificationTime(index),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 区切り線
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    // 詳細メッセージ
                    Text(
                      _getNotificationDetailMessage(index),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // アクションボタン
                    if (_getNotificationActionButton(index) != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_getNotificationActionButton(index)!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_getNotificationActionButton(index)!),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // 閉じるボタン
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('閉じる'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
        return '新しい求人';
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
        return 'あなたのエリアで新しい求人が追加されました。';
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

  String _getNotificationDetailMessage(int index) {
    switch (index % 4) {
      case 0:
        return '''あなたのエリアで新しい配達求人が追加されました。

店舗: マクドナルド 渋谷店
配達先: 東京都渋谷区神南1-5-8
報酬: ¥800
距離: 1.2km
推定時間: 15分

この求人は人気が高いため、早めの応募をおすすめします。求人一覧から詳細を確認して、応募してください。''';
      case 1:
        return '''お疲れ様でした！配達が無事完了しました。

注文番号: #${1000 + index}
配達時刻: ${_getNotificationTime(index)}
報酬: ¥${650 + (index * 50)}
評価: ⭐⭐⭐⭐⭐

お客様から高評価をいただきました。引き続き安全運転でよろしくお願いします。''';
      case 2:
        return '''システムメンテナンスのお知らせ

日時: 2026年1月25日（土）2:00 - 5:00
対象: 全サービス

上記時間帯はシステムメンテナンスのため、アプリをご利用いただけません。ご不便をおかけしますが、ご理解とご協力をお願いいたします。

メンテナンス内容:
- アプリの動作改善
- セキュリティアップデート
- 新機能の追加準備''';
      case 3:
        return '''期間限定キャンペーン実施中！

キャンペーン期間: 1月20日 - 1月31日

特典内容:
🎉 配達10件達成で¥1,000ボーナス
🎉 週末配達で報酬20%アップ
🎉 新規エリアで初回配達¥500ボーナス

この機会にたくさん配達して、ボーナスを獲得しましょう！詳細はマイページのキャンペーン情報をご確認ください。''';
      default:
        return '通知の詳細メッセージがここに表示されます。';
    }
  }

  String? _getNotificationActionButton(int index) {
    switch (index % 4) {
      case 0:
        return '求人を見る';
      case 1:
        return '配達履歴を確認';
      case 2:
        return null; // システムお知らせにはアクションボタンなし
      case 3:
        return 'キャンペーン詳細';
      default:
        return null;
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