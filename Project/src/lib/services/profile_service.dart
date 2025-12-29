import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // ==========================================
  // Requester Profile
  // ==========================================

  /// 依頼者プロフィールを取得
  Future<dynamic> getRequesterProfile() async {
    try {
      final response = await _apiService.get('/profile/requester');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 依頼者プロフィールを更新
  Future<dynamic> updateRequesterProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put('/profile/requester', profileData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 依頼者の住所一覧を取得
  Future<List<dynamic>> getRequesterAddresses() async {
    try {
      final response = await _apiService.get('/profile/requester/addresses');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// 依頼者の住所を追加
  Future<dynamic> addRequesterAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await _apiService.post('/profile/requester/addresses', addressData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 依頼者の住所を削除
  Future<void> deleteRequesterAddress(int addressId) async {
    try {
      await _apiService.delete('/profile/requester/addresses/$addressId');
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // Deliverer Profile
  // ==========================================

  /// 配達員プロフィールを取得
  Future<dynamic> getDelivererProfile() async {
    try {
      final response = await _apiService.get('/profile/deliverer');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 配達員プロフィールを更新
  Future<dynamic> updateDelivererProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put('/profile/deliverer', profileData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // Current User Profile
  // ==========================================

  /// 現在のユーザープロフィールを取得（ロールに基づく）
  Future<dynamic> getCurrentUserProfile() async {
    try {
      final response = await _apiService.get('/auth/me/profile');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
