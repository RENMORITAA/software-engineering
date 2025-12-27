/// アプリ全体で使用する定数
class AppConstants {
  // アプリ情報
  static const String appName = 'Stellar Delivery';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'おいしさを、あなたのもとへ';

  // API
  static const String apiBaseUrl = 'http://localhost:8000';
  static const int apiTimeoutSeconds = 30;

  // ストレージキー
  static const String authTokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // 配達料金
  static const int baseDeliveryFee = 300;
  static const int freeDeliveryThreshold = 3000;

  // ページネーション
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 画像
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

  // 注文
  static const int maxOrderNoteLength = 200;
  static const int minOrderAmount = 500;

  // 評価
  static const int maxRating = 5;
  static const int minRating = 1;

  // 時間（分）
  static const int estimatedPrepTime = 15;
  static const int estimatedDeliveryTime = 20;
}

/// 注文ステータス定数
class OrderStatusConstants {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String preparing = 'preparing';
  static const String readyForPickup = 'ready_for_pickup';
  static const String pickedUp = 'picked_up';
  static const String delivering = 'delivering';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static const List<String> activeStatuses = [
    pending,
    accepted,
    preparing,
    readyForPickup,
    pickedUp,
    delivering,
  ];

  static const List<String> completedStatuses = [
    delivered,
    cancelled,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return '注文受付待ち';
      case accepted:
        return '注文受付';
      case preparing:
        return '調理中';
      case readyForPickup:
        return '受け取り準備完了';
      case pickedUp:
        return '配達員受け取り済み';
      case delivering:
        return '配達中';
      case delivered:
        return '配達完了';
      case cancelled:
        return 'キャンセル';
      default:
        return status;
    }
  }

  static bool isActive(String status) => activeStatuses.contains(status);
  static bool isCompleted(String status) => completedStatuses.contains(status);
}

/// 通知タイプ定数
class NotificationTypeConstants {
  static const String order = 'order';
  static const String delivery = 'delivery';
  static const String promo = 'promo';
  static const String system = 'system';
}

/// ユーザーロール定数
class UserRoleConstants {
  static const String requester = 'requester';
  static const String deliverer = 'deliverer';
  static const String store = 'store';
  static const String admin = 'admin';

  static String getDisplayName(String role) {
    switch (role) {
      case requester:
        return '依頼者';
      case deliverer:
        return '配達員';
      case store:
        return '店舗';
      case admin:
        return '管理者';
      default:
        return role;
    }
  }
}
