import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _apiService.get('/products/');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStoreProducts(int storeId) async {
    try {
      final response = await _apiService.get('/products/store/$storeId');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createProduct(Map<String, dynamic> productData, int storeId) async {
    try {
      final response = await _apiService.post(
        '/products/?store_id=$storeId',
        productData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

