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

  Future<void> register(String email, String password, String role) async {
    try {
      await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'role': role,
      });
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
}

