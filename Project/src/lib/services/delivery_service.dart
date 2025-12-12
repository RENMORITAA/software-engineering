import '../db_helper.dart';
import '../models/database_models.dart';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  final DbHelper _dbHelper = DbHelper();
  
  DeliveryService._internal();
  
  factory DeliveryService() {
    return _instance;
  }

  // 配達ステータスを更新
  Future<void> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      await _dbHelper.updateDeliveryStatus(deliveryId, status);
      
      // ステータスに応じてタイムスタンプを更新
      final db = await _dbHelper.database;
      final currentTime = DateTime.now().toIso8601String();
      
      switch (status) {
        case 'picked_up':
          await db.update(
            'deliveries',
            {'pickup_time': currentTime},
            where: 'id = ?',
            whereArgs: [deliveryId],
          );
          break;
        case 'delivered':
          await db.update(
            'deliveries',
            {'delivery_time': currentTime},
            where: 'id = ?',
            whereArgs: [deliveryId],
          );
          break;
      }

      // 配達情報を取得して関連する通知を送信
      await _sendDeliveryStatusNotification(deliveryId, status);
    } catch (e) {
      print('配達ステータス更新エラー: $e');
      rethrow;
    }
  }

  // 配達員の現在位置を更新
  Future<void> updateDeliveryLocation(
    int deliveryId,
    double latitude,
    double longitude,
  ) async {
    try {
      await _dbHelper.updateDeliveryLocation(deliveryId, latitude, longitude);
    } catch (e) {
      print('配達位置更新エラー: $e');
      rethrow;
    }
  }

  // 配達員の稼働状況を更新
  Future<void> updateDelivererWorkStatus(int delivererId, String workStatus) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'deliverer_profiles',
        {'work_status': workStatus},
        where: 'id = ?',
        whereArgs: [delivererId],
      );
    } catch (e) {
      print('配達員稼働状況更新エラー: $e');
      rethrow;
    }
  }

  // オンラインの配達員一覧を取得
  Future<List<Map<String, dynamic>>> getAvailableDeliverers() async {
    try {
      final db = await _dbHelper.database;
      
      final deliverersData = await db.rawQuery('''
        SELECT dp.*, u.email
        FROM deliverer_profiles dp
        JOIN users u ON dp.user_id = u.id
        WHERE dp.work_status = 'online'
        ORDER BY dp.name
      ''');
      
      return deliverersData.map((data) => {
        'deliverer': DelivererProfile.fromMap(data).toMap(),
        'email': data['email'],
      }).toList();
    } catch (e) {
      print('利用可能配達員取得エラー: $e');
      rethrow;
    }
  }

  // 配達履歴を取得
  Future<List<Map<String, dynamic>>> getDeliveryHistory(int delivererId) async {
    try {
      final db = await _dbHelper.database;
      
      final deliveryHistoryData = await db.rawQuery('''
        SELECT d.*, o.total_price, o.ordered_at, o.delivery_address,
               sp.store_name, rp.name as requester_name
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        JOIN store_profiles sp ON o.store_id = sp.id
        JOIN requester_profiles rp ON o.requester_id = rp.id
        WHERE o.deliverer_id = (
          SELECT id FROM deliverer_profiles WHERE user_id = ?
        )
        ORDER BY d.created_at DESC
      ''', [delivererId]);
      
      return deliveryHistoryData.map((data) => {
        'delivery': Delivery.fromMap(data).toMap(),
        'order_total': data['total_price'],
        'ordered_at': data['ordered_at'],
        'delivery_address': data['delivery_address'],
        'store_name': data['store_name'],
        'requester_name': data['requester_name'],
      }).toList();
    } catch (e) {
      print('配達履歴取得エラー: $e');
      rethrow;
    }
  }

  // 現在進行中の配達を取得
  Future<Map<String, dynamic>?> getCurrentDelivery(int delivererId) async {
    try {
      final db = await _dbHelper.database;
      
      final currentDeliveryData = await db.rawQuery('''
        SELECT d.*, o.*, sp.store_name, sp.address as store_address,
               rp.name as requester_name
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        JOIN store_profiles sp ON o.store_id = sp.id
        JOIN requester_profiles rp ON o.requester_id = rp.id
        WHERE o.deliverer_id = (
          SELECT id FROM deliverer_profiles WHERE user_id = ?
        )
        AND d.status NOT IN ('delivered', 'cancelled')
        ORDER BY d.created_at DESC
        LIMIT 1
      ''', [delivererId]);
      
      if (currentDeliveryData.isNotEmpty) {
        final data = currentDeliveryData.first;
        return {
          'delivery': Delivery.fromMap(data).toMap(),
          'order': Order.fromMap(data).toMap(),
          'store_name': data['store_name'],
          'store_address': data['store_address'],
          'requester_name': data['requester_name'],
        };
      }
      
      return null;
    } catch (e) {
      print('現在の配達取得エラー: $e');
      rethrow;
    }
  }

  // 配達統計を取得
  Future<Map<String, dynamic>> getDeliveryStats(int delivererId) async {
    try {
      final db = await _dbHelper.database;
      
      // 今月の配達件数
      final thisMonthData = await db.rawQuery('''
        SELECT COUNT(*) as count, SUM(o.total_price) as total_earnings
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        WHERE o.deliverer_id = (
          SELECT id FROM deliverer_profiles WHERE user_id = ?
        )
        AND d.status = 'delivered'
        AND strftime('%Y-%m', d.delivery_time) = strftime('%Y-%m', 'now')
      ''', [delivererId]);
      
      // 今週の配達件数
      final thisWeekData = await db.rawQuery('''
        SELECT COUNT(*) as count
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        WHERE o.deliverer_id = (
          SELECT id FROM deliverer_profiles WHERE user_id = ?
        )
        AND d.status = 'delivered'
        AND strftime('%Y-%W', d.delivery_time) = strftime('%Y-%W', 'now')
      ''', [delivererId]);
      
      // 総配達件数
      final totalData = await db.rawQuery('''
        SELECT COUNT(*) as count, AVG(o.total_price) as avg_order_value
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        WHERE o.deliverer_id = (
          SELECT id FROM deliverer_profiles WHERE user_id = ?
        )
        AND d.status = 'delivered'
      ''', [delivererId]);
      
      return {
        'thisMonthDeliveries': thisMonthData.first['count'] ?? 0,
        'thisMonthEarnings': thisMonthData.first['total_earnings'] ?? 0,
        'thisWeekDeliveries': thisWeekData.first['count'] ?? 0,
        'totalDeliveries': totalData.first['count'] ?? 0,
        'averageOrderValue': totalData.first['avg_order_value'] ?? 0,
      };
    } catch (e) {
      print('配達統計取得エラー: $e');
      rethrow;
    }
  }

  // 配達時間の推定
  Future<int> estimateDeliveryTime(
    double storeLatitude,
    double storeLongitude,
    double customerLatitude,
    double customerLongitude,
  ) async {
    try {
      // 簡単な距離計算（実際にはGoogle Maps APIなどを使用することを推奨）
      final distance = _calculateDistance(
        storeLatitude,
        storeLongitude,
        customerLatitude,
        customerLongitude,
      );
      
      // 平均速度を時速30kmと仮定して配達時間を計算（分）
      final estimatedMinutes = (distance / 30 * 60).ceil();
      
      // 最低15分、最大120分とする
      return estimatedMinutes.clamp(15, 120);
    } catch (e) {
      print('配達時間推定エラー: $e');
      return 30; // デフォルト値
    }
  }

  // 2点間の距離を計算（km）
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 地球の半径（km）
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * 
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  // 配達ステータス変更時の通知送信
  Future<void> _sendDeliveryStatusNotification(int deliveryId, String status) async {
    try {
      final db = await _dbHelper.database;
      
      // 配達情報と関連する注文情報を取得
      final deliveryData = await db.rawQuery('''
        SELECT d.*, o.requester_id, o.deliverer_id
        FROM deliveries d
        JOIN orders o ON d.order_id = o.id
        WHERE d.id = ?
      ''', [deliveryId]);
      
      if (deliveryData.isNotEmpty) {
        final data = deliveryData.first;
        final requesterId = data['requester_id'] as int;
        final delivererId = data['deliverer_id'] as int?;
        
        String statusMessage = '';
        switch (status) {
          case 'en_route_to_store':
            statusMessage = '配達員が店舗に向かっています';
            break;
          case 'at_store':
            statusMessage = '配達員が店舗に到着しました';
            break;
          case 'picked_up':
            statusMessage = '商品をお受け取りしました。配達を開始します';
            break;
          case 'en_route_to_customer':
            statusMessage = '配達中です。まもなくお届けします';
            break;
          case 'delivered':
            statusMessage = '配達が完了しました';
            break;
        }
        
        if (statusMessage.isNotEmpty) {
          // 依頼者に通知
          final notification = Notification(
            userId: requesterId,
            title: '配達状況更新',
            message: statusMessage,
            type: 'delivery',
          );
          
          await _dbHelper.insertNotification(notification.toMap());
        }
      }
    } catch (e) {
      print('配達ステータス通知エラー: $e');
      // 通知の失敗は配達処理を止めない
    }
  }

  // 配達経路の最適化（簡易版）
  Future<List<Map<String, dynamic>>> optimizeDeliveryRoute(
    List<Map<String, dynamic>> deliveries,
  ) async {
    try {
      // 簡単な最適化：距離順でソート
      // 実際の実装では、より高度なアルゴリズム（TSP）を使用することを推奨
      deliveries.sort((a, b) {
        final distanceA = a['distance'] ?? 0.0;
        final distanceB = b['distance'] ?? 0.0;
        return distanceA.compareTo(distanceB);
      });
      
      return deliveries;
    } catch (e) {
      print('配達経路最適化エラー: $e');
      return deliveries;
    }
  }
}
