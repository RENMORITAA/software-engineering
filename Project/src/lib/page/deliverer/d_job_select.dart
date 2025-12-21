import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../component/d_job.dart';

/// 求人選択画面
class DJobSelectPage extends StatefulWidget {
  const DJobSelectPage({super.key});

  @override
  State<DJobSelectPage> createState() => _DJobSelectPageState();
}

class _DJobSelectPageState extends State<DJobSelectPage> {
  // モックデータ
  final List<Map<String, dynamic>> _jobs = [
    {
      'id': 1,
      'storeName': 'テスト食堂',
      'storeAddress': '香美市土佐山田町1-1',
      'deliveryAddress': '香美市土佐山田町2-2',
      'reward': 500,
      'distance': 1.2,
      'time': 15,
    },
    {
      'id': 2,
      'storeName': 'カフェ モカ',
      'storeAddress': '香美市土佐山田町3-3',
      'deliveryAddress': '香美市土佐山田町4-4',
      'reward': 450,
      'distance': 0.8,
      'time': 10,
    },
    {
      'id': 3,
      'storeName': 'ラーメン太郎',
      'storeAddress': '香美市土佐山田町5-5',
      'deliveryAddress': '香美市土佐山田町6-6',
      'reward': 600,
      'distance': 2.5,
      'time': 25,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '求人を探す',
        showBackButton: false,
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          // フィルターバー
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'エリア・店舗名で検索',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: フィルター設定
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  onPressed: () {
                    // TODO: 地図から探す画面へ遷移
                  },
                ),
              ],
            ),
          ),
          // 求人リスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _jobs.length,
              itemBuilder: (context, index) {
                return DJobCard(
                  job: _jobs[index],
                  onTap: () {
                    _showJobDetail(_jobs[index]);
                  },
                  onButtonPressed: () {
                    _acceptJob(_jobs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetail(Map<String, dynamic> job) {
    // TODO: 求人詳細画面へ遷移
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['storeName'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 詳細情報...
                  SingleButton(
                    text: '受諾する',
                    onPressed: () {
                      Navigator.pop(context);
                      _acceptJob(job);
                    },
                    color: const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptJob(Map<String, dynamic> job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('求人を受諾'),
        content: Text('${job['storeName']}の配達を受諾しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配達を受諾しました')),
              );
              // TODO: 配達画面へ遷移
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('受諾する'),
          ),
        ],
      ),
    );
  }
}
