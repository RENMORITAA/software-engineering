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
    this.deliveryAddress = '高知県香美市',
    this.storeLatitude = 33.5944, // デフォルト: 高知工科大学付近
    this.storeLongitude = 133.8628,
    this.customerLatitude = 33.5850, // デフォルト: 香美市内
    this.customerLongitude = 133.8750,
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
