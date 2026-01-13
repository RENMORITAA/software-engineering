import 'dart:async';
import 'package:flutter/foundation.dart';

/// 位置情報を表すクラス
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'altitude': altitude,
    'speed': speed,
    'heading': heading,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    accuracy: (json['accuracy'] as num?)?.toDouble(),
    altitude: (json['altitude'] as num?)?.toDouble(),
    speed: (json['speed'] as num?)?.toDouble(),
    heading: (json['heading'] as num?)?.toDouble(),
    timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp']) 
        : null,
  );

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude)';
}

/// 位置情報サービス
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamController<LocationData>? _locationController;
  Timer? _mockTimer;

  /// 現在位置を取得
  Future<LocationData?> getCurrentLocation() async {
    // geolocatorパッケージを使用する場合:
    // final position = await Geolocator.getCurrentPosition();
    // return LocationData(
    //   latitude: position.latitude,
    //   longitude: position.longitude,
    //   accuracy: position.accuracy,
    //   altitude: position.altitude,
    //   speed: position.speed,
    //   heading: position.heading,
    // );

    // 開発用モックデータ（香美市周辺）
    if (kDebugMode) {
      return LocationData(
        latitude: 33.5944,  // 香美市の緯度
        longitude: 133.8628,  // 香美市の経度
        accuracy: 10.0,
      );
    }
    return null;
  }

  /// 位置情報の権限を確認
  Future<bool> checkPermission() async {
    // geolocatorパッケージを使用する場合:
    // final permission = await Geolocator.checkPermission();
    // return permission == LocationPermission.always || 
    //        permission == LocationPermission.whileInUse;

    // 開発用は常にtrue
    return true;
  }

  /// 位置情報の権限をリクエスト
  Future<bool> requestPermission() async {
    // geolocatorパッケージを使用する場合:
    // final permission = await Geolocator.requestPermission();
    // return permission == LocationPermission.always || 
    //        permission == LocationPermission.whileInUse;

    return true;
  }

  /// 位置情報の追跡を開始
  Stream<LocationData> startTracking({
    int intervalSeconds = 5,
  }) {
    _locationController?.close();
    _locationController = StreamController<LocationData>.broadcast();

    // geolocatorパッケージを使用する場合:
    // Geolocator.getPositionStream(
    //   locationSettings: LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: 10,
    //   ),
    // ).listen((position) {
    //   _locationController?.add(LocationData(...));
    // });

    // 開発用モック（位置が少しずつ変化）
    if (kDebugMode) {
      double lat = 33.5944;
      double lng = 133.8628;

      _mockTimer?.cancel();
      _mockTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
        // ランダムに少し移動
        lat += (DateTime.now().millisecond % 10 - 5) * 0.0001;
        lng += (DateTime.now().millisecond % 10 - 5) * 0.0001;

        _locationController?.add(LocationData(
          latitude: lat,
          longitude: lng,
          accuracy: 10.0,
          speed: 5.0,
        ));
      });
    }

    return _locationController!.stream;
  }

  /// 位置情報の追跡を停止
  void stopTracking() {
    _mockTimer?.cancel();
    _mockTimer = null;
    _locationController?.close();
    _locationController = null;
  }

  /// 2点間の距離を計算（メートル）
  static double calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    // Haversine formula
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a = 
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLng / 2) * _sin(dLng / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * 3.141592653589793 / 180;
  static double _sin(double x) => _taylorSin(x);
  static double _cos(double x) => _taylorCos(x);
  static double _sqrt(double x) => _newtonSqrt(x);
  static double _atan2(double y, double x) {
    // 簡易実装
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  static double _atan(double x) {
    // Taylor series approximation
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * 3.141592653589793 / 2 - _atan(1 / x);
    }
    double result = 0;
    double term = x;
    for (int n = 0; n < 20; n++) {
      result += term / (2 * n + 1);
      term *= -x * x;
    }
    return result;
  }
  static double _taylorSin(double x) {
    x = x % (2 * 3.141592653589793);
    double result = 0;
    double term = x;
    for (int n = 1; n <= 20; n++) {
      result += term;
      term *= -x * x / ((2 * n) * (2 * n + 1));
    }
    return result;
  }
  static double _taylorCos(double x) {
    x = x % (2 * 3.141592653589793);
    double result = 0;
    double term = 1;
    for (int n = 0; n <= 20; n++) {
      result += term;
      term *= -x * x / ((2 * n + 1) * (2 * n + 2));
    }
    return result;
  }
  static double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// 距離を読みやすい形式に変換
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 推定到着時間を計算
  static String estimateArrivalTime(double meters, {double speedKmh = 30}) {
    final double hours = meters / 1000 / speedKmh;
    final int minutes = (hours * 60).round();

    if (minutes < 1) return '1分以内';
    if (minutes < 60) return '約$minutes分';
    
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    return '約$h時間$m分';
  }
}
