import 'api_service.dart';

class DeliveryService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getDeliveryJobs() async {
    try {
      final response = await _apiService.get('/delivery/jobs');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptJob(int orderId, int delivererId) async {
    try {
      await _apiService.post(
        '/delivery/jobs/$orderId/accept?deliverer_id=$delivererId',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }
}

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
