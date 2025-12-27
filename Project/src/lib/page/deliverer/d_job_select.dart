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
    final jobs = deliveryProvider.availableJobs;

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
                : jobs.isEmpty
                    ? const Center(child: Text('現在、利用可能な求人はありません'))
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<DeliveryProvider>().fetchDeliveryJobs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobs[index];
                            // Map<String, dynamic> に変換して渡す
                            final jobMap = {
                              'id': job['id'],
                              'storeName': job['store_name'],
                              'storeAddress': job['store_address'],
                              'deliveryAddress': job['delivery_address'],
                              'reward': job['reward'],
                              'distance': job['distance'] ?? 0.0,
                              'time': 15, // 仮
                            };

                            return DJobCard(
                              job: jobMap,
                              onTap: () {
                                // 詳細表示など
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
