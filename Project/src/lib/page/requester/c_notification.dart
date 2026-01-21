import 'package:flutter/material.dart';
import "../../component/component.dart"; // TitleAppBarが含まれている想定

class CNotificationPage extends StatefulWidget {
  const CNotificationPage({super.key});

  @override
  State<CNotificationPage> createState() => _CNotificationPageState();
}

class _CNotificationPageState extends State<CNotificationPage> {
  // 簡易的な既読管理（実際はDBのread_at等で判定）
  final List<bool> _readStatus = List.generate(10, (index) => index % 3 == 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '通知',
        backgroundColor: Color(0xFFE64A19), // 依頼者側のテーマカラー（オレンジ系等）
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          final bool isRead = _readStatus[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: isRead ? Colors.white : const Color(0xFFFFF3E0), // 未読は薄いオレンジ
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[300] : const Color(0xFFE64A19),
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
                  fontSize: 15,
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
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getNotificationTime(index),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: !isRead
                  ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE64A19), shape: BoxShape.circle))
                  : null,
              onTap: () {
                setState(() => _readStatus[index] = true);
                _showNotificationDetail(context, index);
              },
            ),
          );
        },
      ),
    );
  }

  // 詳細表示（ハーフモーダル）
  void _showNotificationDetail(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              Row(
                children: [
                  CircleAvatar(backgroundColor: const Color(0xFFE64A19), child: Icon(_getNotificationIcon(index), color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_getNotificationTitle(index), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              const Divider(height: 40),
              Text(_getNotificationDetailMessage(index), style: const TextStyle(fontSize: 15, height: 1.6)),
              const SizedBox(height: 30),
              if (_getNotificationActionButton(index) != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE64A19), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                    onPressed: () => Navigator.pop(context),
                    child: Text(_getNotificationActionButton(index)!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ヘルパー関数群 ---
  IconData _getNotificationIcon(int index) {
    switch (index % 4) {
      case 0: return Icons.check_circle_outline; // 注文確定
      case 1: return Icons.delivery_dining;      // 配達中
      case 2: return Icons.local_offer_outlined; // クーポン
      default: return Icons.info_outline;        // お知らせ
    }
  }

  String _getNotificationTitle(int index) {
    switch (index % 4) {
      case 0: return '注文が確定しました';
      case 1: return '商品がまもなく到着します';
      case 2: return '限定クーポン配布中！';
      default: return '運営からのお知らせ';
    }
  }

  String _getNotificationMessage(int index) {
    switch (index % 4) {
      case 0: return '注文番号 #8829 の受付が完了しました。';
      case 1: return '配達員があなたの住所に向かっています。';
      case 2: return '本日限定で使える500円OFFクーポンが届きました。';
      default: return 'サービスアップデートに伴う規約改定のお知らせ。';
    }
  }

  String _getNotificationDetailMessage(int index) {
    switch (index % 4) {
      case 0: return 'ご注文ありがとうございます。店舗が商品の準備を開始しました。到着予定時刻は 12:45 ごろです。';
      case 1: return '配達員が商品を受け取り、出発しました。アプリ内のマップから現在地を確認いただけます。';
      case 2: return '日頃の感謝を込めて、全店舗で使えるクーポンをプレゼント！【コード: SMILE2026】を注文確認画面で入力してください。';
      default: return 'より安全・便利にご利用いただくため、利用規約の一部を改定いたしました。詳細は公式サイトをご確認ください。';
    }
  }

  String? _getNotificationActionButton(int index) {
    switch (index % 4) {
      case 0: case 1: return '注文状況を確認';
      case 2: return 'クーポンをコピー';
      default: return null;
    }
  }

  String _getNotificationTime(int index) {
    if (index == 0) return 'たった今';
    return '${index}時間前';
  }
}