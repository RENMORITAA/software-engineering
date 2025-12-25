import 'api_service.dart';

class StoreService {
  final ApiService _apiService = ApiService();

  /// 全店舗一覧を取得
  Future<List<dynamic>> getStores() async {
    try {
      final response = await _apiService.get('/stores/');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 特定の店舗を取得
  Future<dynamic> getStore(int storeId) async {
    try {
      final response = await _apiService.get('/stores/$storeId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 自分の店舗プロフィールを取得
  Future<dynamic> getMyStoreProfile() async {
    try {
      final response = await _apiService.get('/stores/my/profile');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 自分の店舗プロフィールを更新
  Future<dynamic> updateMyStoreProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put('/stores/my/profile', profileData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 店舗の営業状態を切り替え
  Future<dynamic> toggleStoreOpen() async {
    try {
      final response = await _apiService.put('/stores/my/toggle-open', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
