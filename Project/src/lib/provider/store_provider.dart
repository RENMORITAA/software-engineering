import 'package:flutter/material.dart';
import '../services/store_service.dart';
import '../services/product_service.dart';

class StoreProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  final ProductService _productService = ProductService();

  List<dynamic> _stores = [];
  List<dynamic> _products = [];
  Map<String, dynamic>? _myStoreProfile;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get stores => _stores;
  List<dynamic> get products => _products;
  Map<String, dynamic>? get myStoreProfile => _myStoreProfile;
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

  /// 特定店舗の商品一覧を取得
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

  /// 自分の店舗プロフィールを取得
  Future<void> fetchMyStoreProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myStoreProfile = await _storeService.getMyStoreProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 自分の店舗の商品一覧を取得
  Future<void> fetchMyStoreProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // まず店舗プロフィールを取得してstoreIdを取得
      if (_myStoreProfile == null) {
        await fetchMyStoreProfile();
      }
      
      if (_myStoreProfile != null && _myStoreProfile!['id'] != null) {
        final storeId = _myStoreProfile!['id'] as int;
        _products = await _productService.getStoreProducts(storeId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 自分の店舗プロフィールを更新
  Future<bool> updateMyStoreProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myStoreProfile = await _storeService.updateMyStoreProfile(profileData);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 店舗の営業状態を切り替え
  Future<bool> toggleStoreOpen() async {
    try {
      final result = await _storeService.toggleStoreOpen();
      _myStoreProfile = result;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 商品を追加
  Future<bool> addProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.createProduct(productData);
      await fetchMyStoreProducts(); // 商品一覧を再取得
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 商品を更新
  Future<bool> updateProduct(int productId, Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.updateProduct(productId, productData);
      await fetchMyStoreProducts(); // 商品一覧を再取得
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 商品の販売状態を切り替え
  Future<bool> updateProductAvailability(int productId, bool isAvailable) async {
    try {
      await _productService.updateProduct(productId, {
        'is_available': isAvailable,
      });
      await fetchMyStoreProducts(); // 商品一覧を再取得
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 商品の在庫数を更新
  Future<bool> updateProductStock(int productId, int stockQuantity) async {
    try {
      await _productService.updateProduct(productId, {
        'stock_quantity': stockQuantity,
      });
      await fetchMyStoreProducts(); // 商品一覧を再取得
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 商品を削除
  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _productService.deleteProduct(productId);
      await fetchMyStoreProducts(); // 商品一覧を再取得
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}