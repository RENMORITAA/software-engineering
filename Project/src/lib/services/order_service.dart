import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  /// 注文を作成
  Future<dynamic> createOrder({
    required int storeId,
    required String deliveryAddress,
    required List<Map<String, dynamic>> details,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/orders/',
        {
          'store_id': storeId,
          'delivery_address': deliveryAddress,
          'delivery_latitude': deliveryLatitude,
          'delivery_longitude': deliveryLongitude,
          'notes': notes,
          'details': details,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 自分の注文履歴を取得
  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _apiService.get('/orders/my');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 注文詳細を取得
  Future<dynamic> getOrder(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 注文ステータスを更新
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _apiService.put(
        '/orders/$orderId/status',
        {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 店舗の保留中注文を取得
  Future<List<dynamic>> getStorePendingOrders() async {
    try {
      final response = await _apiService.get('/orders/store/pending');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

