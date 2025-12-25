import 'api_service.dart';

class DeliveryService {
  final ApiService _apiService = ApiService();

  /// 配達可能なジョブ一覧を取得
  Future<List<dynamic>> getDeliveryJobs() async {
    try {
      final response = await _apiService.get('/delivery/jobs');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 配達ジョブを受諾
  Future<Map<String, dynamic>> acceptJob(int orderId) async {
    try {
      final response = await _apiService.post(
        '/delivery/jobs/$orderId/accept',
        {},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 自分の配達履歴を取得
  Future<List<dynamic>> getMyDeliveries() async {
    try {
      final response = await _apiService.get('/delivery/my');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 配達ステータスを更新
  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      await _apiService.put(
        '/delivery/$deliveryId/status',
        {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 配達員の現在位置を更新
  Future<void> updateLocation(int deliveryId, double latitude, double longitude) async {
    try {
      await _apiService.put(
        '/delivery/$deliveryId/location',
        {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 配達員をオンラインに設定
  Future<void> setOnline() async {
    try {
      await _apiService.put('/delivery/status/online', {});
    } catch (e) {
      rethrow;
    }
  }

  /// 配達員をオフラインに設定
  Future<void> setOffline() async {
    try {
      await _apiService.put('/delivery/status/offline', {});
    } catch (e) {
      rethrow;
    }
  }
}
