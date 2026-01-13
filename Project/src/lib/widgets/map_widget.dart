import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// Google Maps風の地図表示ウィジェット
/// 
/// 実際のGoogle Maps Flutter パッケージを使用する場合は
/// google_maps_flutter パッケージをインポートし、
/// GoogleMap ウィジェットに置き換えてください。
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
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double _currentLat = 33.5944;  // 香美市
  double _currentLng = 133.8628;
  double _zoom = 15;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLatitude ?? 33.5944;
    _currentLng = widget.initialLongitude ?? 133.8628;
    _zoom = widget.initialZoom;
  }

  @override
  Widget build(BuildContext context) {
    // 実際のGoogle Maps実装の場合:
    // return GoogleMap(
    //   initialCameraPosition: CameraPosition(
    //     target: LatLng(_currentLat, _currentLng),
    //     zoom: _zoom,
    //   ),
    //   markers: _buildMarkers(),
    //   polylines: widget.showRoute ? _buildPolylines() : {},
    //   myLocationEnabled: widget.showCurrentLocation,
    //   myLocationButtonEnabled: true,
    //   onTap: (latLng) => widget.onMapTap?.call(latLng.latitude, latLng.longitude),
    // );

    // モック地図表示
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 地図背景（グリッド表示）
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),

          // 中央のクロスヘア
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          ),

          // 現在位置マーカー
          if (widget.showCurrentLocation)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              top: MediaQuery.of(context).size.height * 0.3,
              child: _buildCurrentLocationMarker(),
            ),

          // 目的地マーカー
          if (widget.showDestination && 
              widget.destinationLatitude != null && 
              widget.destinationLongitude != null)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.3,
              top: MediaQuery.of(context).size.height * 0.2,
              child: _buildDestinationMarker(),
            ),

          // ズームコントロール
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, () {
                  setState(() => _zoom = (_zoom + 1).clamp(1, 20));
                }),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, () {
                  setState(() => _zoom = (_zoom - 1).clamp(1, 20));
                }),
              ],
            ),
          ),

          // 現在位置ボタン
          Positioned(
            right: 16,
            bottom: 50,
            child: FloatingActionButton.small(
              onPressed: () {
                // 現在位置に移動
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('現在位置を取得中...')),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // 座標表示
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentLat.toStringAsFixed(4)}, ${_currentLng.toStringAsFixed(4)}\nズーム: ${_zoom.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),

          // 地図プロバイダー表示
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Map Preview',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return GestureDetector(
      onTap: () => widget.onMarkerTap?.call(_currentLat, _currentLng),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Text(
            '現在地',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationMarker() {
    return GestureDetector(
      onTap: () => widget.onMarkerTap?.call(
        widget.destinationLatitude!,
        widget.destinationLongitude!,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Text(
            '目的地',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 20,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}

/// 地図グリッドを描画するペインター
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // グリッド線を描画
    const double spacing = 50;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 道路風の線を描画
    final roadPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // 横の道路
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );

    // 縦の道路
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 配達追跡用の地図ウィジェット
class DeliveryTrackingMap extends StatelessWidget {
  final LocationData? delivererLocation;
  final LocationData? destinationLocation;
  final String? delivererName;
  final String? estimatedArrival;

  const DeliveryTrackingMap({
    super.key,
    this.delivererLocation,
    this.destinationLocation,
    this.delivererName,
    this.estimatedArrival,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地図
        Expanded(
          child: MapWidget(
            initialLatitude: delivererLocation?.latitude,
            initialLongitude: delivererLocation?.longitude,
            showCurrentLocation: delivererLocation != null,
            showDestination: destinationLocation != null,
            destinationLatitude: destinationLocation?.latitude,
            destinationLongitude: destinationLocation?.longitude,
          ),
        ),

        // 情報パネル
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
          child: Row(
            children: [
              // 配達員アイコン
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.delivery_dining, color: Colors.white),
              ),
              const SizedBox(width: 16),

              // 配達情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      delivererName ?? '配達員',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (estimatedArrival != null)
                      Text(
                        '到着予定: $estimatedArrival',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

              // 連絡ボタン
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
        ),
      ],
    );
  }
}
