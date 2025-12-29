import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        {
          'username': email,
          'password': password,
        },
        isFormData: true,
      );

      final token = response['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        // ロールなどの情報も保存する場合はここでデコードするか、APIレスポンスに含める
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phoneNumber,
    // 店舗用
    String? storeName,
    String? storeAddress,
    String? storeDescription,
    String? businessHours,
    // 配達員用
    String? vehicleType,
  }) async {
    try {
      // ユーザー登録
      final userResponse = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'role': role,
      });

      // 登録成功後、プロフィール情報を更新
      // まずログインしてトークンを取得
      await login(email, password);

      // ロールに応じたプロフィール更新
      if (role == 'requester' && name != null) {
        await _apiService.put('/profile/requester', {
          'name': name,
          'phone_number': phoneNumber,
        });
      } else if (role == 'deliverer' && name != null) {
        await _apiService.put('/profile/deliverer', {
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType,
        });
      } else if (role == 'store' && storeName != null) {
        await _apiService.put('/profile/store', {
          'store_name': storeName,
          'address': storeAddress,
          'description': storeDescription,
          'phone_number': phoneNumber,
          'business_hours': businessHours,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRequesterProfile() async {
    try {
      final response = await _apiService.get('/profile/requester');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDelivererProfile() async {
    try {
      final response = await _apiService.get('/profile/deliverer');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStoreProfile() async {
    try {
      final response = await _apiService.get('/profile/store');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

