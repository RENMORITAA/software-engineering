import 'package:flutter/material.dart';

import '../models/database_models.dart';

/// カートアイテム
class CartItem {
  final Product product;
  int quantity;
  String? notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  int get subtotal => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'unit_price': product.price,
      'subtotal': subtotal,
      'notes': notes,
    };
  }
}

/// カート管理のためのProvider
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  int? _selectedStoreId;
  String? _selectedStoreName;
  String _deliveryAddress = '';
  String _notes = '';

  // ゲッター
  List<CartItem> get items => List.unmodifiable(_items);
  int? get selectedStoreId => _selectedStoreId;
  String? get selectedStoreName => _selectedStoreName;
  String get deliveryAddress => _deliveryAddress;
  String get notes => _notes;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// 小計を計算
  int get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// 配達料（仮: 300円固定）
  int get deliveryFee => _items.isNotEmpty ? 300 : 0;

  /// 合計金額
  int get totalPrice => subtotal + deliveryFee;

  /// 商品をカートに追加
  void addItem(Product product, {int quantity = 1, String? notes}) {
    // 異なる店舗の商品はカートをクリア
    if (_selectedStoreId != null && _selectedStoreId != product.storeId) {
      clear();
    }

    _selectedStoreId = product.storeId;

    // 既存のアイテムを探す
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
      if (notes != null) {
        _items[existingIndex].notes = notes;
      }
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        notes: notes,
      ));
    }

    notifyListeners();
  }

  /// 商品の数量を更新
  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// 商品をカートから削除
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    if (_items.isEmpty) {
      _selectedStoreId = null;
      _selectedStoreName = null;
    }
    notifyListeners();
  }

  /// 配達先住所を設定
  void setDeliveryAddress(String address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  /// 備考を設定
  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  /// 店舗名を設定
  void setStoreName(String storeName) {
    _selectedStoreName = storeName;
    notifyListeners();
  }

  /// カートをクリア
  void clear() {
    _items.clear();
    _selectedStoreId = null;
    _selectedStoreName = null;
    _deliveryAddress = '';
    _notes = '';
    notifyListeners();
  }

  /// カートの内容をマップに変換（注文作成用）
  Map<String, dynamic> toOrderMap(int requesterId) {
    return {
      'requester_id': requesterId,
      'store_id': _selectedStoreId,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total_price': totalPrice,
      'delivery_address': _deliveryAddress,
      'notes': _notes,
      'items': _items.map((item) => item.toMap()).toList(),
    };
  }
}
