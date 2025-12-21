import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<dynamic> createOrder(int storeId, List<Map<String, dynamic>> details, int requesterId) async {
    try {
      final response = await _apiService.post(
        '/orders/?requester_id=$requesterId',
        {
          'store_id': storeId,
          'details': details,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _apiService.put(
        '/orders/$orderId/status?status=$status',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }
}

