import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  /// 自分の通知一覧を取得
  Future<List<dynamic>> getNotifications({int skip = 0, int limit = 50}) async {
    try {
      final response = await _apiService.get('/notifications/?skip=$skip&limit=$limit');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 未読通知数を取得
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread/count');
      return response['unread_count'] as int;
    } catch (e) {
      rethrow;
    }
  }

  /// 通知を既読にする
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiService.put('/notifications/$notificationId/read', {});
    } catch (e) {
      rethrow;
    }
  }

  /// 全通知を既読にする
  Future<void> markAllAsRead() async {
    try {
      await _apiService.put('/notifications/read-all', {});
    } catch (e) {
      rethrow;
    }
  }
}
