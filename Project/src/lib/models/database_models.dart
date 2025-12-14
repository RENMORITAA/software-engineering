// ユーザーモデル
class User {
  final int? id;
  final String email;
  final String password;
  final String role;
  final String? createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      createdAt: map['created_at'],
    );
  }
}

// 依頼者プロフィール
class RequesterProfile {
  final int? id;
  final int userId;
  final String name;
  final String? phone;
  final String? address;
  final String? creditCardInfo;
  final String? createdAt;

  RequesterProfile({
    this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.address,
    this.creditCardInfo,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'credit_card_info': creditCardInfo,
      'created_at': createdAt,
    };
  }

  factory RequesterProfile.fromMap(Map<String, dynamic> map) {
    return RequesterProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'],
      address: map['address'],
      creditCardInfo: map['credit_card_info'],
      createdAt: map['created_at'],
    );
  }
}

// 配達員プロフィール
class DelivererProfile {
  final int? id;
  final int userId;
  final String name;
  final String? phone;
  final String? resume;
  final String workStatus;
  final String? bankAccountInfo;
  final String? vehicleType;
  final String? licenseNumber;
  final String? createdAt;

  DelivererProfile({
    this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.resume,
    this.workStatus = 'offline',
    this.bankAccountInfo,
    this.vehicleType,
    this.licenseNumber,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'resume': resume,
      'work_status': workStatus,
      'bank_account_info': bankAccountInfo,
      'vehicle_type': vehicleType,
      'license_number': licenseNumber,
      'created_at': createdAt,
    };
  }

  factory DelivererProfile.fromMap(Map<String, dynamic> map) {
    return DelivererProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'],
      resume: map['resume'],
      workStatus: map['work_status'] ?? 'offline',
      bankAccountInfo: map['bank_account_info'],
      vehicleType: map['vehicle_type'],
      licenseNumber: map['license_number'],
      createdAt: map['created_at'],
    );
  }
}

// 店舗プロフィール
class StoreProfile {
  final int? id;
  final int userId;
  final String storeName;
  final String address;
  final String? phone;
  final String? businessLicense;
  final String? businessHours;
  final String? bankAccountInfo;
  final String? createdAt;

  StoreProfile({
    this.id,
    required this.userId,
    required this.storeName,
    required this.address,
    this.phone,
    this.businessLicense,
    this.businessHours,
    this.bankAccountInfo,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'address': address,
      'phone': phone,
      'business_license': businessLicense,
      'business_hours': businessHours,
      'bank_account_info': bankAccountInfo,
      'created_at': createdAt,
    };
  }

  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      storeName: map['store_name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'],
      businessLicense: map['business_license'],
      businessHours: map['business_hours'],
      bankAccountInfo: map['bank_account_info'],
      createdAt: map['created_at'],
    );
  }
}

// 商品モデル
class Product {
  final int? id;
  final int storeId;
  final String name;
  final String? description;
  final int price;
  final String? category;
  final String? imageUrl;
  final bool isAvailable;
  final String? createdAt;

  Product({
    this.id,
    required this.storeId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt(),
      storeId: map['store_id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price']?.toInt() ?? 0,
      category: map['category'],
      imageUrl: map['image_url'],
      isAvailable: (map['is_available'] ?? 1) == 1,
      createdAt: map['created_at'],
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
  final int totalPrice;
  final String deliveryAddress;
  final String? notes;
  final String? orderedAt;

  Order({
    this.id,
    required this.requesterId,
    required this.storeId,
    this.delivererId,
    this.status = 'pending',
    required this.totalPrice,
    required this.deliveryAddress,
    this.notes,
    this.orderedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requester_id': requesterId,
      'store_id': storeId,
      'deliverer_id': delivererId,
      'status': status,
      'total_price': totalPrice,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'ordered_at': orderedAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt(),
      requesterId: map['requester_id']?.toInt() ?? 0,
      storeId: map['store_id']?.toInt() ?? 0,
      delivererId: map['deliverer_id']?.toInt(),
      status: map['status'] ?? 'pending',
      totalPrice: map['total_price']?.toInt() ?? 0,
      deliveryAddress: map['delivery_address'] ?? '',
      notes: map['notes'],
      orderedAt: map['ordered_at'],
    );
  }
}

// 注文明細モデル
class OrderDetail {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final int unitPrice;

  OrderDetail({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      id: map['id']?.toInt(),
      orderId: map['order_id']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      quantity: map['quantity']?.toInt() ?? 0,
      unitPrice: map['unit_price']?.toInt() ?? 0,
    );
  }
}

// 配達モデル
class Delivery {
  final int? id;
  final int orderId;
  final String? pickupTime;
  final String? deliveryTime;
  final String status;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? createdAt;

  Delivery({
    this.id,
    required this.orderId,
    this.pickupTime,
    this.deliveryTime,
    this.status = 'assigned',
    this.currentLatitude,
    this.currentLongitude,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'pickup_time': pickupTime,
      'delivery_time': deliveryTime,
      'status': status,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'created_at': createdAt,
    };
  }

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      id: map['id']?.toInt(),
      orderId: map['order_id']?.toInt() ?? 0,
      pickupTime: map['pickup_time'],
      deliveryTime: map['delivery_time'],
      status: map['status'] ?? 'assigned',
      currentLatitude: map['current_latitude']?.toDouble(),
      currentLongitude: map['current_longitude']?.toDouble(),
      createdAt: map['created_at'],
    );
  }
}

// 通知モデル
class Notification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? createdAt;

  Notification({
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

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
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
