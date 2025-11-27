import 'dart:convert';
import 'package:http/http.dart' as http;

class DbHelper {
  // PostgREST APIのエンドポイント
  // Androidエミュレーターなら 'http://10.0.2.2:3000'
  // Web/iOSなら 'http://localhost:3000'
  // Docker内部通信ではなく、クライアント（ブラウザ/スマホ）からのアクセスになるため localhost でOK
  static const String _baseUrl = 'http://localhost:3000';

  // 接続テスト（APIが生きているか確認）
  Future<void> connect() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));
      if (response.statusCode == 200) {
        print('API Connection Successful');
      } else {
        // PostgRESTのルートはOpenAPI定義を返すので200 OKになるはず
        print('API Connection Status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Connection Error: $e');
      // WebではCORSエラーなどもここでキャッチされる
      rethrow;
    }
  }

  // init.sqlで作ったデータを取得するテスト関数
  Future<List<Map<String, dynamic>>> getTodos() async {
    // PostgRESTはテーブル名をそのままパスにする
    final url = Uri.parse('$_baseUrl/todos');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // JSONデコードしてList<Map>として返す
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }
  }
}