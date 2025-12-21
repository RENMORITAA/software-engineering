import 'package:flutter/material.dart';

import '../models/database_models.dart';
import '../services/order_service.dart';

/// 注文状態
enum OrderStatus {
  pending,         // 注文受付待ち
  accepted,        // 店舗が受付
  preparing,       // 調理中
  readyForPickup,  // 受け取り準備完了
  pickedUp,        // 配達員が受け取り
  delivering,      // 配達中
  delivered,       // 配達完了
  cancelled,       // キャンセル
}

/// 注文管理のためのProvider
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  // ゲッター
  List<Order> get orders => List.unmodifiable(_orders);
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 依頼者の注文履歴を取得
  Future<void> fetchRequesterOrders(int requesterId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getRequesterOrders(requesterId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 店舗の注文一覧を取得
  Future<void> fetchStoreOrders(int storeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getStoreOrders(storeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 配達員の配達履歴を取得
  Future<void> fetchDelivererOrders(int delivererId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getDelivererOrders(delivererId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 注文詳細を取得
  Future<void> fetchOrderDetail(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentOrder = await _orderService.getOrderById(orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 注文を作成
  Future<int?> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderId = await _orderService.createOrder(orderData);
      return orderId;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 注文ステータスを更新
  Future<bool> updateOrderStatus(int orderId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _orderService.updateOrderStatus(orderId, status);
      // 現在の注文を更新
      if (_currentOrder?.id == orderId) {
        _currentOrder = await _orderService.getOrderById(orderId);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 注文をキャンセル
  Future<bool> cancelOrder(int orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _orderService.cancelOrder(orderId, reason);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// エラーをクリア
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 注文ステータスの表示名を取得
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return '注文受付待ち';
      case 'accepted':
        return '注文受付';
      case 'preparing':
        return '調理中';
      case 'ready_for_pickup':
        return '受け取り準備完了';
      case 'picked_up':
        return '配達員受け取り済み';
      case 'delivering':
        return '配達中';
      case 'delivered':
        return '配達完了';
      case 'cancelled':
        return 'キャンセル';
      default:
        return status;
    }
  }

  /// 注文ステータスの色を取得
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready_for_pickup':
        return Colors.teal;
      case 'picked_up':
        return Colors.indigo;
      case 'delivering':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
