// import 'package:http/http.dart' as http; // 後で追加

class ApiService {
  // Dockerコンテナ内のバックエンドURL (Android Emulatorからは 10.0.2.2)
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<void> login(String email, String password) async {
    // TODO: バックエンドへのログインリクエスト実装
    // final response = await http.post(Uri.parse('$baseUrl/auth/login'), body: {...});
    await Future.delayed(const Duration(seconds: 1)); // 擬似ウェイト
  }

  Future<List<dynamic>> fetchProducts() async {
    // TODO: 商品一覧取得
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}