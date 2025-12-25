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

  /// 注文をキャンセル
  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      await _apiService.put(
        '/orders/$orderId/status',
        {
          'status': 'cancelled',
          'notes': reason,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 依頼者の注文履歴を取得 (自分の注文)
  Future<List<dynamic>> getRequesterOrders(int requesterId) async {
    // バックエンドは現在のユーザーの注文を返すため、IDは無視されるか、
    // 将来的に管理者機能として実装される可能性があります。
    // 現状は getMyOrders を使用します。
    return getMyOrders();
  }

  /// 店舗の注文履歴を取得 (自分の店舗)
  Future<List<dynamic>> getStoreOrders(int storeId) async {
    return getMyOrders();
  }

  /// 配達員の配達履歴を取得 (自分の配達)
  Future<List<dynamic>> getDelivererOrders(int delivererId) async {
    return getMyOrders();
  }

  /// 注文詳細を取得 (ID指定)
  Future<dynamic> getOrderById(int orderId) async {
    return getOrder(orderId);
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

