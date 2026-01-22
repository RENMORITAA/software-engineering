import 'dart:async';
import 'location_service.dart';

/// 配達員の位置をシミュレートするサービス
/// 実際の実装では、バックエンドAPIから位置情報を取得します
class DeliverySimulationService {
  StreamController<LocationData>? _locationController;
  Timer? _timer;
  
  List<LocationData>? _routePoints;
  int _currentIndex = 0;

  /// 配達シミュレーションを開始
  /// routePoints: OSRMから取得したルート上の座標リスト
  Stream<LocationData> startSimulation({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    int updateIntervalSeconds = 5,
  }) {
    _locationController?.close();
    _locationController = StreamController<LocationData>.broadcast();

    // 簡易的にスタートとゴールの間を10分割した座標を生成
    _routePoints = _generateRoutePoints(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      steps: 20,
    );

    _currentIndex = 0;

    // 定期的に位置を更新
    _timer = Timer.periodic(Duration(seconds: updateIntervalSeconds), (timer) {
      if (_currentIndex < _routePoints!.length) {
        final location = _routePoints![_currentIndex];
        _locationController!.add(location);
        _currentIndex++;
      } else {
        // ゴールに到達したらシミュレーション終了
        timer.cancel();
        _locationController!.close();
      }
    });

    // 初回の位置をすぐに送信
    if (_routePoints!.isNotEmpty) {
      _locationController!.add(_routePoints![0]);
    }

    return _locationController!.stream;
  }

  /// シミュレーションを停止
  void stopSimulation() {
    _timer?.cancel();
    _locationController?.close();
    _locationController = null;
    _timer = null;
  }

  /// スタートからゴールまでの簡易ルートポイントを生成
  List<LocationData> _generateRoutePoints({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required int steps,
  }) {
    final points = <LocationData>[];
    
    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;
      
      // 線形補間で座標を計算
      final lat = startLat + (endLat - startLat) * progress;
      final lng = startLng + (endLng - startLng) * progress;
      
      points.add(LocationData(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now().add(Duration(seconds: i * 5)),
      ));
    }
    
    return points;
  }

  /// 実際のバックエンドAPIから配達員の位置を取得する場合の実装例
  Stream<LocationData> fetchDelivererLocationFromApi({
    required int deliveryId,
    int pollIntervalSeconds = 5,
  }) {
    final controller = StreamController<LocationData>.broadcast();

    // 定期的にAPIをポーリング
    Timer.periodic(Duration(seconds: pollIntervalSeconds), (timer) async {
      try {
        // TODO: 実際のAPI呼び出し
        // final response = await http.get('/delivery/$deliveryId/location');
        // final data = jsonDecode(response.body);
        // final location = LocationData(
        //   latitude: data['latitude'],
        //   longitude: data['longitude'],
        //   timestamp: DateTime.parse(data['timestamp']),
        // );
        // controller.add(location);
      } catch (e) {
        print('配達員位置取得エラー: $e');
      }
    });

    return controller.stream;
  }

  void dispose() {
    stopSimulation();
  }
}
