import 'package:flutter/material.dart';
import '../models/database_models.dart';
import '../services/delivery_service.dart';

class DeliveryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _availableJobs = [];
  List<Map<String, dynamic>> _myDeliveries = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = false;

  List<Map<String, dynamic>> get availableJobs => _availableJobs;
  List<Map<String, dynamic>> get myDeliveries => _myDeliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  /// 配達可能なジョブ一覧を取得（ダミーデータ版）
  Future<void> fetchDeliveryJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      // API呼び出しをシミュレート
      await Future.delayed(const Duration(seconds: 1));

      // ダミーの求人データ
      _availableJobs = [
        {
          'id': 'job_001',
          'store_name': 'マクドナルド 渋谷店',
          'store_address': '東京都渋谷区道玄坂1-2-3',
          'delivery_address': '東京都渋谷区神南1-5-8',
          'reward': 800,
          'distance': 1.2,
          'time': 15,
        },
        {
          'id': 'job_002',
          'store_name': 'スターバックス 新宿店',
          'store_address': '東京都新宿区新宿3-14-1',
          'delivery_address': '東京都新宿区西新宿1-6-1',
          'reward': 650,
          'distance': 0.8,
          'time': 10,
        },
        {
          'id': 'job_003',
          'store_name': 'すき家 池袋東口店',
          'store_address': '東京都豊島区南池袋1-28-1',
          'delivery_address': '東京都豊島区東池袋1-10-1',
          'reward': 900,
          'distance': 1.5,
          'time': 20,
        },
        {
          'id': 'job_004',
          'store_name': 'ガスト 品川店',
          'store_address': '東京都港区高輪3-13-1',
          'delivery_address': '東京都港区高輪4-10-18',
          'reward': 750,
          'distance': 1.0,
          'time': 12,
        },
        {
          'id': 'job_005',
          'store_name': 'CoCo壱番屋 秋葉原店',
          'store_address': '東京都千代田区外神田1-15-9',
          'delivery_address': '東京都千代田区神田練塀町3',
          'reward': 850,
          'distance': 1.3,
          'time': 18,
        },
        {
          'id': 'job_006',
          'store_name': '吉野家 上野店',
          'store_address': '東京都台東区上野6-1-6',
          'delivery_address': '東京都台東区東上野2-18-6',
          'reward': 700,
          'distance': 0.9,
          'time': 11,
        },
        {
          'id': 'job_007',
          'store_name': 'ケンタッキー 六本木店',
          'store_address': '東京都港区六本木3-2-1',
          'delivery_address': '東京都港区六本木7-4-4',
          'reward': 950,
          'distance': 1.8,
          'time': 22,
        },
        {
          'id': 'job_008',
          'store_name': 'サイゼリヤ 中野店',
          'store_address': '東京都中野区中野5-52-15',
          'delivery_address': '東京都中野区本町2-31-2',
          'reward': 600,
          'distance': 0.7,
          'time': 9,
        },
        {
          'id': 'job_009',
          'store_name': 'デニーズ 目黒店',
          'store_address': '東京都品川区上大崎2-13-45',
          'delivery_address': '東京都品川区上大崎3-1-1',
          'reward': 800,
          'distance': 1.1,
          'time': 14,
        },
        {
          'id': 'job_010',
          'store_name': 'モスバーガー 恵比寿店',
          'store_address': '東京都渋谷区恵比寿南1-5-5',
          'delivery_address': '東京都渋谷区恵比寿4-20-3',
          'reward': 880,
          'distance': 1.4,
          'time': 17,
        },
      ];

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ジョブを受諾
  Future<bool> acceptJob(dynamic jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // API呼び出しをシミュレート
      await Future.delayed(const Duration(seconds: 1));

      // 受諾した求人を配達リストに追加
      final job = _availableJobs.firstWhere((j) => j['id'] == jobId);
      _myDeliveries.add({
        'id': 'delivery_${DateTime.now().millisecondsSinceEpoch}',
        'store_name': job['store_name'],
        'deliveryFee': job['reward'],
        'status': 'accepted',
      });

      // 利用可能な求人リストから削除
      _availableJobs.removeWhere((j) => j['id'] == jobId);

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
      // API呼び出しをシミュレート
      await Future.delayed(const Duration(milliseconds: 500));

      // ダミーの配達履歴データ
      _myDeliveries = [
        {
          'id': 'delivery_001',
          'store_name': 'マクドナルド 渋谷店',
          'deliveryFee': 800,
          'status': 'completed',
        },
        {
          'id': 'delivery_002',
          'store_name': 'スターバックス 新宿店',
          'deliveryFee': 650,
          'status': 'completed',
        },
        {
          'id': 'delivery_003',
          'store_name': 'すき家 池袋東口店',
          'deliveryFee': 900,
          'status': 'completed',
        },
      ];

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// オンライン/オフラインステータスを切り替え
  Future<void> toggleOnlineStatus(bool value) async {
    final previous = _isOnline;

    _isOnline = value;
    _isLoading = true;
    notifyListeners();

    try {
      // API呼び出しをシミュレート
      await Future.delayed(const Duration(milliseconds: 500));

      if (value) {
        // オンラインになったら求人を取得
        try {
          await fetchDeliveryJobs();
        } catch (e) {
          debugPrint('fetchDeliveryJobs failed: $e');
        }
      }
    } catch (e) {
      _isOnline = previous;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 配達ステータス更新
  Future<bool> updateDeliveryStatus(int deliveryId, String status) async {
    try {
      // API呼び出しをシミュレート
      await Future.delayed(const Duration(milliseconds: 500));

      await fetchMyDeliveries();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}