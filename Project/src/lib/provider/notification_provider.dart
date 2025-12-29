import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/notification_service.dart';

/// 通知管理のためのProvider
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // ゲッター
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  /// 通知一覧を取得
  Future<void> fetchNotifications({int skip = 0, int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<dynamic> response = await _notificationService.getNotifications(
        skip: skip,
        limit: limit,
      );
      _notifications = response.map((data) => AppNotification.fromMap(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 未読件数を取得
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// 通知を既読にする
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // ローカルの状態を更新
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final updated = AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _notifications[index] = updated;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  /// 全通知を既読にする
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      // ローカルの状態を更新
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// エラーをクリア
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 通知アイコンを取得
  static IconData getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long;
      case 'delivery':
        return Icons.local_shipping;
      case 'promo':
        return Icons.local_offer;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  /// 通知アイコンの色を取得
  static Color getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'delivery':
        return Colors.green;
      case 'promo':
        return Colors.orange;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
