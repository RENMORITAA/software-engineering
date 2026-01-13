import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/location_provider.dart';
import '../../widgets/map_widget.dart';
import '../../services/location_service.dart';

/// 配達マップ画面
class DMapPage extends StatefulWidget {
  const DMapPage({super.key});

  @override
  State<DMapPage> createState() => _DMapPageState();
}

class _DMapPageState extends State<DMapPage> {
  // 現在の配達タスク（nullの場合は待機中）
  Map<String, dynamic>? _currentTask;

  @override
  void initState() {
    super.initState();
    // 初期位置を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      locationProvider.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Stack(
            children: [
              // マップウィジェット
              MapWidget(
                initialLatitude: locationProvider.currentLocation?.latitude,
                initialLongitude: locationProvider.currentLocation?.longitude,
                showCurrentLocation: true,
                showDestination: _currentTask != null,
                destinationLatitude: _currentTask?['destinationLat'] as double?,
                destinationLongitude: _currentTask?['destinationLng'] as double?,
                onMapTap: (lat, lng) {
                  // デバッグ用：タップした位置を表示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('位置: $lat, $lng')),
                  );
                },
              ),

              // 位置追跡ステータス
              if (locationProvider.isTracking)
                Positioned(
                  top: 60,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          '追跡中',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              // ローディング
              if (locationProvider.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              
              // ステータスオーバーレイ
              if (_currentTask == null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '現在配達中の注文はありません',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (locationProvider.currentLocation != null)
                          Text(
                            '現在地: ${locationProvider.currentLocation!.latitude.toStringAsFixed(4)}, ${locationProvider.currentLocation!.longitude.toStringAsFixed(4)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SingleButton(
                                text: '求人を探す',
                                onPressed: () {
                                  // 求人タブへ切り替え
                                },
                                color: const Color(0xFF2E7D32),
                                icon: Icons.search,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // デバッグ用：配達シミュレーション
                        OutlinedButton.icon(
                          onPressed: _startDemoDelivery,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('配達デモを開始'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildDeliveryStatusPanel(locationProvider),
            ],
          );
        },
      ),
    );
  }

  void _startDemoDelivery() {
    final locationProvider = context.read<LocationProvider>();
    
    // デモ配達を開始
    setState(() {
      _currentTask = {
        'id': 'demo-1',
        'storeName': 'テスト食堂',
        'storeAddress': '香美市土佐山田町1-1',
        'destinationLat': 33.5950,
        'destinationLng': 133.8650,
        'customerName': '山田太郎',
        'customerAddress': '香美市土佐山田町2-2',
      };
    });

    // 目的地を設定
    locationProvider.setTargetLocation(33.5950, 133.8650);
    
    // 位置追跡を開始
    locationProvider.startTracking(intervalSeconds: 3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配達デモを開始しました')),
    );
  }

  void _endDemoDelivery() {
    final locationProvider = context.read<LocationProvider>();
    
    locationProvider.stopTracking();
    locationProvider.clearTargetLocation();
    
    setState(() {
      _currentTask = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配達を完了しました')),
    );
  }

  Widget _buildDeliveryStatusPanel(LocationProvider locationProvider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '店舗へ向かっています',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(locationProvider.estimatedArrival),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 距離表示
            Text(
              '残り距離: ${locationProvider.formattedDistance}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.store, color: Colors.white),
              ),
              title: Text(_currentTask?['storeName'] ?? 'テスト食堂'),
              subtitle: Text(_currentTask?['storeAddress'] ?? '香美市土佐山田町1-1'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showDeliveryDetails();
                    },
                    child: const Text('詳細'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _endDemoDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text('配達完了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryDetails() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配達詳細',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.store, '店舗', _currentTask?['storeName'] ?? '-'),
            _buildDetailRow(Icons.location_on, '店舗住所', _currentTask?['storeAddress'] ?? '-'),
            _buildDetailRow(Icons.person, 'お客様', _currentTask?['customerName'] ?? '-'),
            _buildDetailRow(Icons.home, 'お届け先', _currentTask?['customerAddress'] ?? '-'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
