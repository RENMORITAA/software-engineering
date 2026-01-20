import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../component/d_job.dart';
import '../../provider/provider.dart';

/// 求人選択画面
class DJobSelectPage extends StatefulWidget {
  const DJobSelectPage({super.key});

  @override
  State<DJobSelectPage> createState() => _DJobSelectPageState();
}

class _DJobSelectPageState extends State<DJobSelectPage> {
  String _searchQuery = '';
  
  // ダミーデータ
  final List<Map<String, dynamic>> _dummyJobs = [
    {
      'id': 'job_001',
      'store_name': 'マクドナルド 渋谷店',
      'store_address': '東京都渋谷区道玄坂1-2-3',
      'delivery_address': '東京都渋谷区神南1-5-8',
      'reward': 800,
      'distance': 1.2,
      'time': 15,
    },
    {
      'id': 'job_002',
      'store_name': 'スターバックス 新宿店',
      'store_address': '東京都新宿区新宿3-14-1',
      'delivery_address': '東京都新宿区西新宿1-6-1',
      'reward': 650,
      'distance': 0.8,
      'time': 10,
    },
    {
      'id': 'job_003',
      'store_name': 'すき家 池袋東口店',
      'store_address': '東京都豊島区南池袋1-28-1',
      'delivery_address': '東京都豊島区東池袋1-10-1',
      'reward': 900,
      'distance': 1.5,
      'time': 20,
    },
    {
      'id': 'job_004',
      'store_name': 'ガスト 品川店',
      'store_address': '東京都港区高輪3-13-1',
      'delivery_address': '東京都港区高輪4-10-18',
      'reward': 750,
      'distance': 1.0,
      'time': 12,
    },
    {
      'id': 'job_005',
      'store_name': 'CoCo壱番屋 秋葉原店',
      'store_address': '東京都千代田区外神田1-15-9',
      'delivery_address': '東京都千代田区神田練塀町3',
      'reward': 850,
      'distance': 1.3,
      'time': 18,
    },
    {
      'id': 'job_006',
      'store_name': '吉野家 上野店',
      'store_address': '東京都台東区上野6-1-6',
      'delivery_address': '東京都台東区東上野2-18-6',
      'reward': 700,
      'distance': 0.9,
      'time': 11,
    },
    {
      'id': 'job_007',
      'store_name': 'ケンタッキー 六本木店',
      'store_address': '東京都港区六本木3-2-1',
      'delivery_address': '東京都港区六本木7-4-4',
      'reward': 950,
      'distance': 1.8,
      'time': 22,
    },
    {
      'id': 'job_008',
      'store_name': 'サイゼリヤ 中野店',
      'store_address': '東京都中野区中野5-52-15',
      'delivery_address': '東京都中野区本町2-31-2',
      'reward': 600,
      'distance': 0.7,
      'time': 9,
    },
    {
      'id': 'job_009',
      'store_name': 'デニーズ 目黒店',
      'store_address': '東京都品川区上大崎2-13-45',
      'delivery_address': '東京都品川区上大崎3-1-1',
      'reward': 800,
      'distance': 1.1,
      'time': 14,
    },
    {
      'id': 'job_010',
      'store_name': 'モスバーガー 恵比寿店',
      'store_address': '東京都渋谷区恵比寿南1-5-5',
      'delivery_address': '東京都渋谷区恵比寿4-20-3',
      'reward': 880,
      'distance': 1.4,
      'time': 17,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchDeliveryJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    
    // Providerから取得したデータとダミーデータを結合
    final jobs = deliveryProvider.availableJobs.isEmpty 
        ? _dummyJobs 
        : deliveryProvider.availableJobs;
    
    final filteredJobs = jobs.where((job) {
      final query = _searchQuery.toLowerCase();

      final storeName =
          (job['store_name'] ?? '').toString().toLowerCase();
      final storeAddress =
          (job['store_address'] ?? '').toString().toLowerCase();

      return storeName.contains(query) ||
          storeAddress.contains(query);
    }).toList();

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
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'エリア・店舗名で検索',
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: const Text('距離が近い順'),
                            onTap: () {
                              // ここに処理を書く
                              Navigator.pop(context); // シートを閉じる
                            },
                          ),
                          ListTile(
                            title: const Text('報酬が高い順'),
                            onTap: () {
                              // ここに処理を書く
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<DeliveryProvider>().fetchDeliveryJobs();
                  },
                ),
              ],
            ),
          ),
          // 求人リスト
          Expanded(
            child: deliveryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredJobs.isEmpty
                    ? const Center(child: Text('現在、利用可能な求人はありません'))
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<DeliveryProvider>().fetchDeliveryJobs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            // Map<String, dynamic> に変換して渡す
                            final jobMap = {
                              'id': job['id'],
                              'storeName': job['store_name'],
                              'storeAddress': job['store_address'],
                              'deliveryAddress': job['delivery_address'],
                              'reward': job['reward'],
                              'distance': job['distance'] ?? 0.0,
                              'time': job['time'] ?? 15,
                            };

                            return DJobCard(
                              job: jobMap,
                              onTap: () {
                                // 詳細表示
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(job['store_name']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('店舗: ${job['store_address']}'),
                                        const SizedBox(height: 8),
                                        Text('配達先: ${job['delivery_address']}'),
                                        const SizedBox(height: 8),
                                        Text('報酬: ¥${job['reward']}'),
                                        const SizedBox(height: 8),
                                        Text('距離: ${job['distance']}km'),
                                        const SizedBox(height: 8),
                                        Text('推定時間: ${job['time']}分'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('閉じる'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onButtonPressed: () async {
                                final success = await context
                                    .read<DeliveryProvider>()
                                    .acceptJob(job['id']);
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('求人を受諾しました')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}