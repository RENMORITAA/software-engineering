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
  double _maxDistance = 5.0; // 最大距離フィルター
  int _minReward = 0; // 最低報酬フィルター
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchDeliveryJobs();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempMaxDistance = _maxDistance;
        int tempMinReward = _minReward;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('フィルター設定'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最大距離',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempMaxDistance,
                          min: 0.5,
                          max: 5.0,
                          divisions: 9,
                          label: '${tempMaxDistance.toStringAsFixed(1)}km',
                          onChanged: (value) {
                            setDialogState(() {
                              tempMaxDistance = value;
                            });
                          },
                        ),
                      ),
                      Text('${tempMaxDistance.toStringAsFixed(1)}km'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '最低報酬',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempMinReward.toDouble(),
                          min: 0,
                          max: 1000,
                          divisions: 10,
                          label: '¥$tempMinReward',
                          onChanged: (value) {
                            setDialogState(() {
                              tempMinReward = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text('¥$tempMinReward'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _maxDistance = 5.0;
                      _minReward = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('リセット'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _maxDistance = tempMaxDistance;
                      _minReward = tempMinReward;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('適用'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliveryProvider = context.watch<DeliveryProvider>();
    final jobs = deliveryProvider.availableJobs;
    
    // フィルタリング処理
    final filteredJobs = jobs.where((job) {
      final query = _searchQuery.toLowerCase();

      // store_nameとstore_addressで検索
      final storeName = (job['store_name'] ?? '').toString().toLowerCase();
      final storeAddress = (job['store_address'] ?? '').toString().toLowerCase();

      final matchesSearch = storeName.contains(query) || storeAddress.contains(query);

      // distanceとrewardでフィルター
      final distance = _parseDouble(job['distance']);
      final reward = _parseInt(job['delivery_fee'] ?? job['reward']);

      final matchesDistance = distance <= _maxDistance;
      final matchesReward = reward >= _minReward;

      return matchesSearch && matchesDistance && matchesReward;
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
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                    if (_maxDistance < 5.0 || _minReward > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
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
          // フィルター適用状態の表示
          if (_maxDistance < 5.0 || _minReward > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE8F5E9),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'フィルター: ${_maxDistance < 5.0 ? '距離 ${_maxDistance.toStringAsFixed(1)}km以下' : ''}${_maxDistance < 5.0 && _minReward > 0 ? '、' : ''}${_minReward > 0 ? '報酬 ¥$_minReward以上' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _maxDistance = 5.0;
                        _minReward = 0;
                      });
                    },
                    child: const Text(
                      'クリア',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // 求人リスト
          Expanded(
            child: deliveryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '現在、利用可能な求人はありません',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'オンラインにすると新しい求人が表示されます',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<DeliveryProvider>().fetchDeliveryJobs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            
                            // バックエンドのデータ構造に合わせてマッピング
                            final jobMap = {
                              'id': job['order_id'] ?? job['id'],
                              'storeName': job['store_name'] ?? '店舗名不明',
                              'storeAddress': job['store_address'] ?? '',
                              'deliveryAddress': job['delivery_address'] ?? '',
                              'reward': _parseInt(job['delivery_fee'] ?? job['reward']),
                              'distance': _parseDouble(job['distance_km'] ?? job['distance']),
                              'time': _parseInt(job['estimated_time'] ?? 15),
                            };

                            return DJobCard(
                              job: jobMap,
                              onTap: () {
                                _showJobDetail(context, job);
                              },
                              onButtonPressed: () async {
                                final orderId = _parseInt(job['order_id'] ?? job['id']);
                                
                                // 確認ダイアログ
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('求人受諾確認'),
                                    content: Text(
                                      '${job['store_name'] ?? '店舗名不明'}の配達を受諾しますか?\n\n報酬: ¥${jobMap['reward']}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('キャンセル'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2E7D32),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('受諾する'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  final success = await context
                                      .read<DeliveryProvider>()
                                      .acceptJob(orderId);
                                  
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('求人を受諾しました'),
                                        backgroundColor: Color(0xFF2E7D32),
                                      ),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '求人の受諾に失敗しました: ${deliveryProvider.error ?? "不明なエラー"}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
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

  void _showJobDetail(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store,
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
                            job['store_name'] ?? '店舗名不明',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            job['store_address'] ?? '',
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
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.location_on, '配達先', job['delivery_address'] ?? ''),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.attach_money, '報酬', '¥${_parseInt(job['delivery_fee'] ?? job['reward'])}'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.straighten, '距離', '${_parseDouble(job['distance_km'] ?? job['distance']).toStringAsFixed(1)}km'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, '推定時間', '${_parseInt(job['estimated_time'] ?? 15)}分'),
                if (job['notes'] != null && job['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.note, '備考', job['notes'].toString()),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('閉じる'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}