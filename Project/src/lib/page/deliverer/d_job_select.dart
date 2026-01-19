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
            // フィルターバ E
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
                      // TODO: フィルター設宁E
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
            // 求人リスチE
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
