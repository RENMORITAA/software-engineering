import 'package:flutter/material.dart';

import '../../component/component.dart';
import '../../widgets/widgets.dart';
import '../../services/delivery_simulation_service.dart';
import '../../services/location_service.dart';

/// 配達中マップ画面（Leaflet + OSRM統合版）
/// 店舗→依頼者のルート表示 + 配達員位置アニメーション
class DDeliveryMapPage extends StatefulWidget {
  final int? orderId;
  final String storeName;
  final String deliveryAddress;
  final double? storeLatitude;
  final double? storeLongitude;
  final double? customerLatitude;
  final double? customerLongitude;

  const DDeliveryMapPage({
    super.key,
    this.orderId,
    this.storeName = 'テスト店舗',
    this.deliveryAddress = '東京都渋谷区',
    this.storeLatitude = 35.6812, // デフォルト: 東京
    this.storeLongitude = 139.7671,
    this.customerLatitude = 35.6895, // デフォルト: 東京近郊
    this.customerLongitude = 139.6917,
  });

  @override
  State<DDeliveryMapPage> createState() => _DDeliveryMapPageState();
}

class _DDeliveryMapPageState extends State<DDeliveryMapPage> {
  final DeliverySimulationService _simulationService = DeliverySimulationService();
  Stream<LocationData>? _delivererLocationStream;

  @override
  void initState() {
    super.initState();
    _startDeliverySimulation();
  }

  @override
  void dispose() {
    _simulationService.dispose();
    super.dispose();
  }

  /// 配達シミュレーションを開始
  void _startDeliverySimulation() {
    if (widget.storeLatitude != null &&
        widget.storeLongitude != null &&
        widget.customerLatitude != null &&
        widget.customerLongitude != null) {
      _delivererLocationStream = _simulationService.startSimulation(
        startLat: widget.storeLatitude!,
        startLng: widget.storeLongitude!,
        endLat: widget.customerLatitude!,
        endLng: widget.customerLongitude!,
        updateIntervalSeconds: 3, // 3秒ごとに位置更新
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: '配達中',
        showBackButton: true,
      ),
      body: DeliveryTrackingMap(
        storeLatitude: widget.storeLatitude,
        storeLongitude: widget.storeLongitude,
        customerLatitude: widget.customerLatitude,
        customerLongitude: widget.customerLongitude,
        storeName: widget.storeName,
        customerAddress: widget.deliveryAddress,
        delivererName: '配達員 田中',
        delivererLocationStream: _delivererLocationStream,
      ),
    );
  }
}
