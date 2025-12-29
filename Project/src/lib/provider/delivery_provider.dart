import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/delivery_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryService _deliveryService = DeliveryService();

  List<dynamic> _availableJobs = [];
  List<Delivery> _myDeliveries = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = false;

  List<dynamic> get availableJobs => _availableJobs;
  List<Delivery> get myDeliveries => _myDeliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  /// 配達可能なジョブ一覧を取得
  Future<void> fetchDeliveryJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableJobs = await _deliveryService.getDeliveryJobs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ジョブを受諾
  Future<bool> acceptJob(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _deliveryService.acceptJob(orderId);
      // ジョブ一覧と自分の配達履歴を更新
      await fetchDeliveryJobs();
      await fetchMyDeliveries();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 自分の配達履歴を取得
  Future<void> fetchMyDeliveries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _deliveryService.getMyDeliveries();
      _myDeliveries = response.map((data) => Delivery.fromMap(data)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// オンライン/オフライン切り替え
  Future<void> toggleOnlineStatus(bool isOnline) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isOnline) {
        await _deliveryService.setOnline();
      } else {
        await _deliveryService.setOffline();
      }
      _isOnline = isOnline;
      if (_isOnline) {
        fetchDeliveryJobs();
      }
    } catch (e) {
      _error = e.toString();
      // エラー時は状態を戻す
      _isOnline = !isOnline;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 配達ステータス更新
  Future<bool> updateDeliveryStatus(int deliveryId, String status) async {
     try {
      await _deliveryService.updateDeliveryStatus(deliveryId, status);
      await fetchMyDeliveries();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
