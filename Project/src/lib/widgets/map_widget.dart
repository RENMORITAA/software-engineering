import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import '../services/location_service.dart';

/// Leaflet + OSRM を使用した配達用地図ウィジェット
/// Web専用実装（Flutter Web向け）
class MapWidget extends StatefulWidget {
  /// 初期位置（緯度）
  final double? initialLatitude;

  /// 初期位置（経度）
  final double? initialLongitude;

  /// 初期ズームレベル
  final double initialZoom;

  /// 現在位置マーカーを表示するか
  final bool showCurrentLocation;

  /// 目的地マーカーを表示するか
  final bool showDestination;

  /// 目的地の緯度
  final double? destinationLatitude;

  /// 目的地の経度
  final double? destinationLongitude;

  /// 経路を表示するか
  final bool showRoute;

  /// 経路のポイントリスト
  final List<LocationData>? routePoints;

  /// マーカータップ時のコールバック
  final void Function(double lat, double lng)? onMarkerTap;

  /// 地図タップ時のコールバック
  final void Function(double lat, double lng)? onMapTap;

  /// ルート情報コールバック（距離・時間）
  final void Function(double distanceKm, int durationMin)? onRouteCalculated;

  /// 配達員の現在位置を更新（アニメーション用）
  final Stream<LocationData>? delivererLocationStream;

  const MapWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 15,
    this.showCurrentLocation = true,
    this.showDestination = false,
    this.destinationLatitude,
    this.destinationLongitude,
    this.showRoute = false,
    this.routePoints,
    this.onMarkerTap,
    this.onMapTap,
    this.onRouteCalculated,
    this.delivererLocationStream,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static int _mapIdCounter = 0;
  late String _mapId;
  bool _mapInitialized = false;
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _mapId = 'delivery-map-${_mapIdCounter++}';
    _initializeMap();
    
    // 配達員位置更新のリスナー
    if (widget.delivererLocationStream != null) {
      _locationSubscription = widget.delivererLocationStream!.listen((location) {
        _updateDelivererMarker(location.latitude, location.longitude);
      });
    }

    // JavaScriptからのメッセージを受信（ルート計算結果）
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'routeCalculated' && data['mapId'] == _mapId) {
        final distance = data['distance'] as double;
        final duration = data['duration'] as int;
        widget.onRouteCalculated?.call(distance, duration);
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initializeMap() {
    // HTMLコンテナを登録
    try {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _mapId,
        (int viewId) {
          print('[MapWidget] Registering platform view: $_mapId');
          final div = html.DivElement()
            ..id = _mapId
            ..style.width = '100%'
            ..style.height = '100%';

          print('[MapWidget] Created div element with id: $_mapId');
          return div;
        },
      );
    } catch (e) {
      print('[MapWidget] Error registering platform view: $e');
    }

    // 少し遅延させてから地図を初期化（DOMがレンダリングされるのを待つ）
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        print('[MapWidget] Initializing Leaflet map for: $_mapId');
        _initLeafletMap();
      }
    });
  }

  void _initLeafletMap() {
    final startLat = widget.initialLatitude ?? 35.6812;
    final startLng = widget.initialLongitude ?? 139.7671;
    final destLat = widget.destinationLatitude;
    final destLng = widget.destinationLongitude;
    final zoom = widget.initialZoom;

    print('[MapWidget] Sending initMap message: mapId=$_mapId, start=($startLat, $startLng), dest=($destLat, $destLng)');

    html.window.postMessage({
      'type': 'initMap',
      'mapId': _mapId,
      'startLat': startLat,
      'startLng': startLng,
      'destLat': destLat,
      'destLng': destLng,
      'zoom': zoom,
      'showRoute': widget.showRoute && destLat != null && destLng != null,
    }, '*');

    setState(() => _mapInitialized = true);
  }

  void _updateDelivererMarker(double lat, double lng) {
    html.window.postMessage({
      'type': 'updateDeliverer',
      'mapId': _mapId,
      'lat': lat,
      'lng': lng,
    }, '*');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Leaflet地図（Web専用）
        HtmlElementView(viewType: _mapId),
        
        // 初期化中の表示
        if (!_mapInitialized)
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('地図を読み込み中...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 配達追跡用の地図ウィジェット（店舗→依頼者のルート表示）
class DeliveryTrackingMap extends StatefulWidget {
  final double? storeLatitude;
  final double? storeLongitude;
  final double? customerLatitude;
  final double? customerLongitude;
  final String? storeName;
  final String? customerAddress;
  final String? delivererName;
  final Stream<LocationData>? delivererLocationStream;

  const DeliveryTrackingMap({
    super.key,
    this.storeLatitude,
    this.storeLongitude,
    this.customerLatitude,
    this.customerLongitude,
    this.storeName,
    this.customerAddress,
    this.delivererName,
    this.delivererLocationStream,
  });

  @override
  State<DeliveryTrackingMap> createState() => _DeliveryTrackingMapState();
}

class _DeliveryTrackingMapState extends State<DeliveryTrackingMap> {
  double? _distanceKm;
  int? _durationMin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地図エリア
        Expanded(
          child: MapWidget(
            initialLatitude: widget.storeLatitude,
            initialLongitude: widget.storeLongitude,
            showCurrentLocation: true,
            showDestination: widget.customerLatitude != null && widget.customerLongitude != null,
            destinationLatitude: widget.customerLatitude,
            destinationLongitude: widget.customerLongitude,
            showRoute: widget.customerLatitude != null && widget.customerLongitude != null,
            delivererLocationStream: widget.delivererLocationStream,
            onRouteCalculated: (distance, duration) {
              setState(() {
                _distanceKm = distance;
                _durationMin = duration;
              });
            },
          ),
        ),

        // 配達情報パネル
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 配達員情報
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.delivery_dining, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.delivererName ?? '配達員',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.customerAddress != null)
                          Text(
                            '配達先: ${widget.customerAddress}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('配達員に連絡中...')),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    color: Colors.green,
                  ),
                ],
              ),
              
              // ルート情報
              if (_distanceKm != null && _durationMin != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard(
                      icon: Icons.straighten,
                      label: '距離',
                      value: '${_distanceKm!.toStringAsFixed(2)} km',
                    ),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      label: '所要時間',
                      value: '約 $_durationMin 分',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
