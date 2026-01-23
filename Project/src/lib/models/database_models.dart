// ユーザーモデル
class User {
  final int? id;
  final String email;
  final String? password; // APIレスポンスには含まれない
  final String role;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt; // 追加

  User({
    this.id,
    required this.email,
    this.password,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt, // 追加
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt, // 追加
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'], // レスポンスにはない場合がある
      role: map['role'] ?? '',
      isActive: map['is_active'] ?? true,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'], // 追加
    );
  }
}

// 住所モデル
// ※ 住所テーブルには updated_at がない場合が多いですが、テーブル定義(source:3)にあるため追加します
class RequesterAddress {
  final int? id;
  final int requesterId;
  final String label;
  final String postalCode;
  final String prefecture;
  final String city;
  final String addressLine1;
  final String? addressLine2;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? createdAt; // 元コードになかったがDB定義にあるため念の為追加
  // DB定義(source:3)にはupdated_atがないため、ここでは追加しません(または必要ならDB定義変更後に対応)

  RequesterAddress({
    this.id,
    required this.requesterId,
    this.label = '自宅',
    this.postalCode = '',
    this.prefecture = '',
    this.city = '',
    required this.addressLine1,
    this.addressLine2,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  factory RequesterAddress.fromMap(Map<String, dynamic> map) {
    return RequesterAddress(
      id: map['id']?.toInt(),
      requesterId: map['requester_id']?.toInt() ?? 0,
      label: map['label'] ?? '自宅',
      postalCode: map['postal_code'] ?? '',
      prefecture: map['prefecture'] ?? '',
      city: map['city'] ?? '',
      addressLine1: map['address_line1'] ?? '',
      addressLine2: map['address_line2'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      isDefault: map['is_default'] ?? false,
      createdAt: map['created_at'],
    );
  }
}

// 依頼者プロフィール
class RequesterProfile {
  final int? id;
  final int userId;
  final String name;
  final String? phoneNumber;
  final int? defaultAddressId;
  final List<RequesterAddress> addresses;
  final String? createdAt; // DB定義(source:2)にあるため追加
  final String? updatedAt; // DB定義(source:2)にあるため追加

  RequesterProfile({
    this.id,
    required this.userId,
    required this.name,
    this.phoneNumber,
    this.defaultAddressId,
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'default_address_id': defaultAddressId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory RequesterProfile.fromMap(Map<String, dynamic> map) {
    return RequesterProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'],
      defaultAddressId: map['default_address_id']?.toInt(),
      addresses: (map['addresses'] as List<dynamic>?)
              ?.map((x) => RequesterAddress.fromMap(x))
              .toList() ??
          [],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

// 配達員プロフィール
class DelivererProfile {
  final int? id;
  final int userId;
  final String name;
  final String? phoneNumber;
  final String? resume;
  final String workStatus;
  final String? bankName;
  final String? bankBranch;
  final String? bankAccountType;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final String? vehicleType;
  final String? licenseNumber;
  final String? profileImageUrl;
  final String? createdAt;
  final String? updatedAt; // 追加

  DelivererProfile({
    this.id,
    required this.userId,
    required this.name,
    this.phoneNumber,
    this.resume,
    this.workStatus = 'offline',
    this.bankName,
    this.bankBranch,
    this.bankAccountType,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.vehicleType,
    this.licenseNumber,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt, // 追加
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'resume': resume,
      'work_status': workStatus,
      'bank_name': bankName,
      'bank_branch': bankBranch,
      'bank_account_type': bankAccountType,
      'bank_account_number': bankAccountNumber,
      'bank_account_holder': bankAccountHolder,
      'vehicle_type': vehicleType,
      'license_number': licenseNumber,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt, // 追加
    };
  }

  factory DelivererProfile.fromMap(Map<String, dynamic> map) {
    return DelivererProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phoneNumber: map['phone_number'],
      resume: map['resume'],
      workStatus: map['work_status'] ?? 'offline',
      bankName: map['bank_name'],
      bankBranch: map['bank_branch'],
      bankAccountType: map['bank_account_type'],
      bankAccountNumber: map['bank_account_number'],
      bankAccountHolder: map['bank_account_holder'],
      vehicleType: map['vehicle_type'],
      licenseNumber: map['license_number'],
      profileImageUrl: map['profile_image_url'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'], // 追加
    );
  }
}

// 店舗プロフィール
class StoreProfile {
  final int? id;
  final int userId;
  final String storeName;
  final String? description;
  final String address;
  final String? postalCode;
  final String? phoneNumber;
  final String? businessLicense;
  final String? businessHours;
  final double? latitude;
  final double? longitude;
  final String? storeImageUrl;
  final bool isOpen;
  final String? createdAt;
  final String? updatedAt; // 追加

  StoreProfile({
    this.id,
    required this.userId,
    required this.storeName,
    this.description,
    required this.address,
    this.postalCode,
    this.phoneNumber,
    this.businessLicense,
    this.businessHours,
    this.latitude,
    this.longitude,
    this.storeImageUrl,
    this.isOpen = true,
    this.createdAt,
    this.updatedAt, // 追加
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'description': description,
      'address': address,
      'postal_code': postalCode,
      'phone_number': phoneNumber,
      'business_license': businessLicense,
      'business_hours': businessHours,
      'latitude': latitude,
      'longitude': longitude,
      'store_image_url': storeImageUrl,
      'is_open': isOpen,
      'created_at': createdAt,
      'updated_at': updatedAt, // 追加
    };
  }

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      storeName: map['store_name'] ?? '',
      description: map['description'],
      address: map['address'] ?? '',
      postalCode: map['postal_code'],
      phoneNumber: map['phone_number'],
      businessLicense: map['business_license'],
      businessHours: map['business_hours'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      storeImageUrl: map['store_image_url'],
      isOpen: map['is_open'] ?? true,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'], // 追加
    );
  }
}

// 商品モデル
class Product {
  final int? id;
  final int storeId;
  final int? categoryId;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final bool isAvailable;
  final int stockQuantity;
  final int displayOrder;
  final String? createdAt;
  final String? updatedAt; // 追加

  Product({
    this.id,
    required this.storeId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.stockQuantity = 0,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt, // 追加
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'stock_quantity': stockQuantity,
      'display_order': displayOrder,
      'created_at': createdAt,
      'updated_at': updatedAt, // 追加
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt(),
      storeId: map['store_id']?.toInt() ?? 0,
      categoryId: map['category_id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price']?.toInt() ?? 0,
      imageUrl: map['image_url'],
      isAvailable: (map['is_available'] ?? 1) == 1,
      stockQuantity: map['stock_quantity']?.toInt() ?? 0,
      displayOrder: map['display_order']?.toInt() ?? 0,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'], // 追加
    );
  }
}

// 注文明細モデル
class OrderDetail {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final String? notes;
  // order_detailsには通常updated_atを持たせないため、ここでは追加していません

  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id']?.toInt(),
      orderId: map['order_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      productName: map['product_name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      unitPrice: map['unit_price']?.toInt() ?? 0,
      subtotal: map['subtotal']?.toInt() ?? 0,
      notes: map['notes'],
    );
  }
}

// 注文モデル
class Order {
  final int? id;
  final int requesterId;
  final int storeId;
  final int? delivererId;
  final String status;
  final int subtotal;
  final int deliveryFee;
  final int totalPrice;
  final String deliveryAddress;
  final String? notes;
  final String? orderedAt;
  final String? acceptedAt;
  final String? completedAt;
  final String? cancelledAt; // DB定義(source:12)にあるため追加
  final List<OrderDetail> orderDetails;

  Order({
    this.id,
    required this.requesterId,
    required this.storeId,
    this.delivererId,
    this.status = 'pending',
    required this.subtotal,
    required this.deliveryFee,
    required this.totalPrice,
    required this.deliveryAddress,
    this.notes,
    this.orderedAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt, // 追加
    this.orderDetails = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requester_id': requesterId,
      'store_id': storeId,
      'deliverer_id': delivererId,
      'status': status,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total_price': totalPrice,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'ordered_at': orderedAt,
      'accepted_at': acceptedAt,
      'completed_at': completedAt,
      'cancelled_at': cancelledAt, // 追加
      'order_details': orderDetails.map((x) => x.toMap()).toList(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt(),
      requesterId: map['requester_id']?.toInt() ?? 0,
      storeId: map['store_id']?.toInt() ?? 0,
      delivererId: map['deliverer_id']?.toInt(),
      status: map['status'] ?? 'pending',
      subtotal: map['subtotal']?.toInt() ?? 0,
      deliveryFee: map['delivery_fee']?.toInt() ?? 0,
      totalPrice: map['total_price']?.toInt() ?? 0,
      deliveryAddress: map['delivery_address'] ?? '',
      notes: map['notes'],
      orderedAt: map['ordered_at'],
      acceptedAt: map['accepted_at'],
      completedAt: map['completed_at'],
      cancelledAt: map['cancelled_at'], // 追加
      orderDetails: (map['order_details'] as List<dynamic>?)
              ?.map((x) => OrderDetail.fromMap(x))
              .toList() ??
          [],
    );
  }
}

// 配達モデル
class Delivery {
  final int? id;
  final int orderId;
  final int delivererId;
  final String? pickupTime;
  final String? deliveryTime;
  final String status;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? distanceKm;
  final int? deliveryFee;
  final String? createdAt;
  final String? updatedAt; // 追加

  Delivery({
    this.id,
    required this.orderId,
    required this.delivererId,
    this.pickupTime,
    this.deliveryTime,
    this.status = 'assigned',
    this.currentLatitude,
    this.currentLongitude,
    this.distanceKm,
    this.deliveryFee,
    this.createdAt,
    this.updatedAt, // 追加
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'deliverer_id': delivererId,
      'pickup_time': pickupTime,
      'delivery_time': deliveryTime,
      'status': status,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'distance_km': distanceKm,
      'delivery_fee': deliveryFee,
      'created_at': createdAt,
      'updated_at': updatedAt, // 追加
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id']?.toInt(),
      orderId: map['order_id']?.toInt() ?? 0,
      delivererId: map['deliverer_id']?.toInt() ?? 0,
      pickupTime: map['pickup_time'],
      deliveryTime: map['delivery_time'],
      status: map['status'] ?? 'assigned',
      currentLatitude: map['current_latitude']?.toDouble(),
      currentLongitude: map['current_longitude']?.toDouble(),
      distanceKm: map['distance_km']?.toDouble(),
      deliveryFee: map['delivery_fee']?.toInt(),
      createdAt: map['created_at'],
      updatedAt: map['updated_at'], // 追加
    );
  }
}

// 通知モデル（FlutterのNotificationと名前衝突を避けるためAppNotificationに命名）
class AppNotification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? createdAt;
  // DB定義(source:18)にはupdated_atがないため追加しません

  AppNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      isRead: (map['is_read'] ?? 0) == 1,
      createdAt: map['created_at'],
    );
  }
}