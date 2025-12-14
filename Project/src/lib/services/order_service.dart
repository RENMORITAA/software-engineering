import '../db_helper.dart';
import '../models/database_models.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  final DbHelper _dbHelper = DbHelper();
  
  OrderService._internal();
  
  factory OrderService() {
    return _instance;
  }

  // 注文を作成
  Future<int> createOrder({
    required int requesterId,
    required int storeId,
    required int totalPrice,
    required String deliveryAddress,
    required List<OrderDetail> orderDetails,
    String? notes,
  }) async {
    try {
      // 注文を作成
      final order = Order(
        requesterId: requesterId,
        storeId: storeId,
        totalPrice: totalPrice,
        deliveryAddress: deliveryAddress,
        notes: notes,
        status: 'pending',
      );

      final orderId = await _dbHelper.insertOrder(order.toMap());

      // 注文明細を追加
      for (final detail in orderDetails) {
        final orderDetail = OrderDetail(
          orderId: orderId,
          productId: detail.productId,
          quantity: detail.quantity,
          unitPrice: detail.unitPrice,
        );
        await _dbHelper.insertOrderDetail(orderDetail.toMap());
      }

      // 店舗に通知を送信
      await _sendNotification(
        storeId,
        '新しい注文',
        '新しい注文が入りました。注文ID: $orderId',
        'order',
      );

      return orderId;
    } catch (e) {
      print('注文作成エラー: $e');
      rethrow;
    }
  }

  // 注文ステータスを更新
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      await _dbHelper.updateOrderStatus(orderId, status);

      // 注文情報を取得してステータス変更通知を送信
      final orderData = await _dbHelper.database.then((db) => 
        db.query('orders', where: 'id = ?', whereArgs: [orderId]));
      
      if (orderData.isNotEmpty) {
        final order = Order.fromMap(orderData.first);
        
        // 依頼者に通知
        await _sendNotification(
          order.requesterId,
          '注文状況更新',
          '注文の状況が「$status」に更新されました。',
          'order',
        );
        
        // 配達員が割り当てられている場合は配達員にも通知
        if (order.delivererId != null) {
          await _sendNotification(
            order.delivererId!,
            '注文状況更新',
            '担当する注文の状況が「$status」に更新されました。',
            'delivery',
          );
        }
      }
    } catch (e) {
      print('注文ステータス更新エラー: $e');
      rethrow;
    }
  }

  // 配達員を注文に割り当て
  Future<void> assignDelivererToOrder(int orderId, int delivererId) async {
    try {
      await _dbHelper.assignDelivererToOrder(orderId, delivererId);

      // 配達情報を作成
      final delivery = Delivery(
        orderId: orderId,
        status: 'assigned',
      );
      await _dbHelper.insertDelivery(delivery.toMap());

      // 配達員に通知
      await _sendNotification(
        delivererId,
        '新しい配達依頼',
        '新しい配達が割り当てられました。注文ID: $orderId',
        'delivery',
      );
    } catch (e) {
      print('配達員割り当てエラー: $e');
      rethrow;
    }
  }

  // 依頼者の注文履歴を取得
  Future<List<Order>> getOrdersByRequester(int requesterId) async {
    try {
      final ordersData = await _dbHelper.getOrdersByRequester(requesterId);
      return ordersData.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('依頼者注文履歴取得エラー: $e');
      rethrow;
    }
  }

  // 店舗の注文一覧を取得
  Future<List<Order>> getOrdersByStore(int storeId) async {
    try {
      final ordersData = await _dbHelper.getOrdersByStore(storeId);
      return ordersData.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('店舗注文一覧取得エラー: $e');
      rethrow;
    }
  }

  // 配達員の配達一覧を取得
  Future<List<Order>> getOrdersByDeliverer(int delivererId) async {
    try {
      final ordersData = await _dbHelper.getOrdersByDeliverer(delivererId);
      return ordersData.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('配達員配達一覧取得エラー: $e');
      rethrow;
    }
  }

  // 利用可能な注文を取得（配達員用）
  Future<List<Order>> getAvailableOrders() async {
    try {
      final ordersData = await _dbHelper.getAvailableOrders();
      return ordersData.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('利用可能注文取得エラー: $e');
      rethrow;
    }
  }

  // 注文の詳細情報を取得（注文明細も含む）
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final db = await _dbHelper.database;
      
      // 注文情報を取得
      final orderData = await db.query(
        'orders',
        where: 'id = ?',
        whereArgs: [orderId],
      );
      
      if (orderData.isEmpty) {
        throw Exception('注文が見つかりません');
      }
      
      final order = Order.fromMap(orderData.first);
      
      // 注文明細を取得
      final orderDetailsData = await db.rawQuery('''
        SELECT od.*, p.name as product_name, p.image_url
        FROM order_details od
        JOIN products p ON od.product_id = p.id
        WHERE od.order_id = ?
      ''', [orderId]);
      
      final orderDetails = orderDetailsData.map((data) => {
        ...OrderDetail.fromMap(data).toMap(),
        'product_name': data['product_name'],
        'image_url': data['image_url'],
      }).toList();
      
      // 店舗情報を取得
      final storeData = await db.query(
        'store_profiles',
        where: 'id = ?',
        whereArgs: [order.storeId],
      );
      
      // 依頼者情報を取得
      final requesterData = await db.query(
        'requester_profiles',
        where: 'id = ?',
        whereArgs: [order.requesterId],
      );
      
      // 配達情報を取得（存在する場合）
      final deliveryData = await _dbHelper.getDeliveryByOrderId(orderId);
      
      return {
        'order': order.toMap(),
        'order_details': orderDetails,
        'store': storeData.isNotEmpty ? StoreProfile.fromMap(storeData.first).toMap() : null,
        'requester': requesterData.isNotEmpty ? RequesterProfile.fromMap(requesterData.first).toMap() : null,
        'delivery': deliveryData != null ? Delivery.fromMap(deliveryData).toMap() : null,
      };
    } catch (e) {
      print('注文詳細取得エラー: $e');
      rethrow;
    }
  }

  // 通知を送信（内部メソッド）
  Future<void> _sendNotification(
    int userId,
    String title,
    String message,
    String type,
  ) async {
    try {
      final notification = Notification(
        userId: userId,
        title: title,
        message: message,
        type: type,
      );
      
      await _dbHelper.insertNotification(notification.toMap());
    } catch (e) {
      print('通知送信エラー: $e');
      // 通知の失敗は注文処理を止めない
    }
  }

  // 注文をキャンセル
  Future<void> cancelOrder(int orderId) async {
    try {
      await updateOrderStatus(orderId, 'cancelled');
      
      // 配達員が割り当てられている場合は配達情報も更新
      final deliveryData = await _dbHelper.getDeliveryByOrderId(orderId);
      if (deliveryData != null) {
        final delivery = Delivery.fromMap(deliveryData);
        await _dbHelper.updateDeliveryStatus(delivery.id!, 'cancelled');
      }
    } catch (e) {
      print('注文キャンセルエラー: $e');
      rethrow;
    }
  }
}
