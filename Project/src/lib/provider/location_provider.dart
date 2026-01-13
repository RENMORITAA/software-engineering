import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/location_service.dart';

/// 位置情報の状態を管理するProvider
class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  LocationData? _currentLocation;
  LocationData? _targetLocation;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<LocationData>? _trackingSubscription;

  // 経路の履歴
  final List<LocationData> _locationHistory = [];

  // ゲッター
  LocationData? get currentLocation => _currentLocation;
  LocationData? get targetLocation => _targetLocation;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LocationData> get locationHistory => List.unmodifiable(_locationHistory);

  /// 目的地までの距離（メートル）
  double? get distanceToTarget {
    if (_currentLocation == null || _targetLocation == null) return null;
    return LocationService.calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _targetLocation!.latitude,
      _targetLocation!.longitude,
    );
  }

  /// 目的地までの距離（フォーマット済み）
  String get formattedDistance {
    final distance = distanceToTarget;
    if (distance == null) return '--';
    return LocationService.formatDistance(distance);
  }

  /// 推定到着時間
  String get estimatedArrival {
    final distance = distanceToTarget;
    if (distance == null) return '--';
    return LocationService.estimateArrivalTime(distance);
  }

  /// 現在位置を取得
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasPermission = await _locationService.checkPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestPermission();
        if (!granted) {
          _errorMessage = '位置情報の権限が必要です';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _currentLocation = await _locationService.getCurrentLocation();
      if (_currentLocation != null) {
        _locationHistory.add(_currentLocation!);
      }
    } catch (e) {
      _errorMessage = '位置情報の取得に失敗しました: $e';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 位置情報の追跡を開始
  void startTracking({int intervalSeconds = 5}) {
    if (_isTracking) return;

    _isTracking = true;
    _errorMessage = null;
    notifyListeners();

    _trackingSubscription = _locationService
        .startTracking(intervalSeconds: intervalSeconds)
        .listen(
      (location) {
        _currentLocation = location;
        _locationHistory.add(location);

        // 履歴が多すぎたら古いものを削除
        if (_locationHistory.length > 1000) {
          _locationHistory.removeRange(0, 500);
        }

        notifyListeners();
      },
      onError: (error) {
        _errorMessage = '位置情報の追跡でエラーが発生しました: $error';
        debugPrint(_errorMessage);
        notifyListeners();
      },
    );
  }

  /// 位置情報の追跡を停止
  void stopTracking() {
    _trackingSubscription?.cancel();
    _trackingSubscription = null;
    _locationService.stopTracking();
    _isTracking = false;
    notifyListeners();
  }

  /// 目的地を設定
  void setTargetLocation(double latitude, double longitude) {
    _targetLocation = LocationData(
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// 目的地をクリア
  void clearTargetLocation() {
    _targetLocation = null;
    notifyListeners();
  }

  /// 位置履歴をクリア
  void clearHistory() {
    _locationHistory.clear();
    notifyListeners();
  }

  /// 配達員の位置を更新（サーバーへ送信用）
  Future<void> updateDeliveryLocation(int orderId) async {
    if (_currentLocation == null) return;

    // TODO: APIを呼んでサーバーに位置を送信
    // await DeliveryService().updateLocation(
    //   orderId: orderId,
    //   latitude: _currentLocation!.latitude,
    //   longitude: _currentLocation!.longitude,
    // );
    debugPrint('配達位置更新: $orderId -> $_currentLocation');
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
