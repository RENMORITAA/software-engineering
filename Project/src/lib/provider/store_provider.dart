import 'package:flutter/material.dart';
import '../services/store_service.dart';
import '../services/product_service.dart';

class StoreProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();

  List<dynamic> _stores = [];
  List<dynamic> _products = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get stores => _stores;
  List<dynamic> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 全店舗一覧を取得
  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stores = await _storeService.getStores();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 店舗の商品一覧を取得
  Future<void> fetchStoreProducts(int storeId) async {
    _isLoading = true;
    _products = []; // クリア
    notifyListeners();

    try {
      _products = await _productService.getStoreProducts(storeId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
