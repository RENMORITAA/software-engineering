import 'package:flutter/material.dart';

/// 利用規約表示オーバーレイ
class RuleScreenOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onAgree;
  final bool showAgreeButton;

  const RuleScreenOverlay({
    super.key,
    required this.onClose,
    this.onAgree,
    this.showAgreeButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '利用規約',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              // 規約本文
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        '第1条（適用）',
                        '本規約は、Stellar Delivery（以下「本サービス」といいます）'
                            'の利用に関する条件を定めるものです。',
                      ),
                      _buildSection(
                        '第2条（利用登録）',
                        '登録希望者が当社の定める方法によって利用登録を申請し、'
                            '当社がこれを承認することによって、利用登録が完了するものとします。',
                      ),
                      _buildSection(
                        '第3条（禁止事項）',
                        '利用者は、本サービスの利用にあたり、以下の行為をしてはなりません。\n'
                            '・法令または公序良俗に違反する行為\n'
                            '・犯罪行為に関連する行為\n'
                            '・当社のサーバーまたはネットワークの機能を破壊したり、'
                            '妨害したりする行為\n'
                            '・当社のサービスの運営を妨害するおそれのある行為',
                      ),
                      _buildSection(
                        '第4条（本サービスの提供の停止等）',
                        '当社は、以下のいずれかの事由があると判断した場合、'
                            '利用者に事前に通知することなく本サービスの全部または'
                            '一部の提供を停止または中断することができるものとします。',
                      ),
                      _buildSection(
                        '第5条（利用制限および登録抹消）',
                        '当社は、利用者が本規約のいずれかの条項に違反した場合、'
                            '事前の通知なく、利用者に対して本サービスの全部もしくは'
                            '一部の利用を制限し、または利用者としての登録を抹消する'
                            'ことができるものとします。',
                      ),
                      _buildSection(
                        '第6条（免責事項）',
                        '当社は、本サービスに事実上または法律上の瑕疵'
                            '（安全性、信頼性、正確性、完全性、有効性、特定の目的への'
                            '適合性、セキュリティなどに関する欠陥を含みます）がないことを'
                            '明示的にも黙示的にも保証しておりません。',
                      ),
                      _buildSection(
                        '第7条（サービス内容の変更等）',
                        '当社は、利用者に通知することなく、本サービスの内容を'
                            '変更しまたは本サービスの提供を中止することができるものとし、'
                            'これによって利用者に生じた損害について一切の責任を負いません。',
                      ),
                      _buildSection(
                        '第8条（利用規約の変更）',
                        '当社は、必要と判断した場合には、利用者に通知することなく'
                            'いつでも本規約を変更することができるものとします。',
                      ),
                      _buildSection(
                        '第9条（準拠法・裁判管轄）',
                        '本規約の解釈にあたっては、日本法を準拠法とします。'
                            '本サービスに関して紛争が生じた場合には、'
                            '高知地方裁判所を専属的合意管轄とします。',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '最終更新日: 2025年12月21日',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // フッター
              if (showAgreeButton)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('閉じる'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAgree,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('同意する'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('閉じる'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
