# Stellar Delivery 開発計画書

**作成日**: 2026年1月13日  
**対象**: 4人チーム開発

---

## 📋 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [現在の実装状況](#2-現在の実装状況)
3. [未実装機能一覧](#3-未実装機能一覧)
4. [優先度別タスクリスト](#4-優先度別タスクリスト)
5. [チーム分担案](#5-チーム分担案)
6. [技術的課題と解決方針](#6-技術的課題と解決方針)
7. [開発環境とツール](#7-開発環境とツール)
8. [品質管理](#8-品質管理)

---

## 1. プロジェクト概要

### プロジェクト名
**Stellar Delivery** - フードデリバリープラットフォーム

### システム構成
- **フロントエンド**: Flutter (Web)
- **バックエンド**: Python (FastAPI)
- **データベース**: PostgreSQL 15
- **インフラ**: Docker / Docker Compose

### ユーザーロール
1. **依頼者 (Requester)**: 商品を注文するユーザー
2. **店舗 (Store)**: 商品を提供する店舗
3. **配達員 (Deliverer)**: 商品を配達する配達員
4. **管理者 (Admin)**: システム全体を管理

### 主要機能
- 注文・決済システム
- リアルタイム配達追跡
- 店舗・商品管理
- 配達員マッチング
- 通知システム
- レビュー・評価

---

## 2. 現在の実装状況

### ✅ 完成している機能

#### バックエンド (FastAPI)
| 機能 | ファイル | 状態 |
|------|----------|------|
| 認証API | `routers/auth.py` | ✅ 完成 |
| ユーザープロフィールAPI | `routers/profile.py` | ✅ 完成 |
| 商品API | `routers/products.py` | ✅ 完成 |
| 注文API | `routers/orders.py` | ✅ 完成 |
| 配達API | `routers/delivery.py` | ✅ 完成 |
| 店舗API | `routers/stores.py` | ✅ 完成 |
| 通知API | `routers/notifications.py` | ✅ 完成 |
| 画像アップロードAPI | `routers/uploads.py` | ✅ 完成 |
| データベース設計 | `models.py`, `init.sql` | ✅ 完成 |

#### フロントエンド (Flutter)
| 機能 | ファイル | 状態 |
|------|----------|------|
| ログイン・新規登録 | `page/login_page.dart`, `page/new_member.dart` | ✅ 完成 |
| ルーティング | `config/routes.dart` | ✅ 完成 |
| 認証ガード | `utils/auth_guard.dart` | ✅ 完成 |
| 状態管理 (Provider) | `provider/*.dart` | ✅ 完成 |
| APIサービス基盤 | `services/api_service.dart` | ✅ 完成 |
| 依頼者ホーム | `page/requester/c_home.dart` | ✅ 完成 |
| 商品一覧 | `page/requester/c_product_list.dart` | ✅ 完成 |
| カート機能 | `page/requester/c_cart.dart` | ✅ 完成 |
| 配達員ホーム | `page/deliverer/d_home.dart` | ✅ 完成 |
| 店舗ホーム | `page/store/s_home.dart` | ✅ 完成 |
| 共通コンポーネント | `component/*.dart`, `widgets/*.dart` | ✅ 完成 |

### ⚠️ 部分実装・要改善

| 機能 | 現状 | 課題 |
|------|------|------|
| 注文履歴画面 | UI基本実装のみ | API連携が不完全 |
| 配達マップ | 画面は存在 | Google Maps統合が未実装 |
| 決済機能 | DBスキーマのみ | 決済ロジックが未実装 |
| 店舗商品管理 | UIのみ | CRUD操作が未実装 |
| プッシュ通知 | ポーリングのみ | WebSocket/FCM未実装 |
| 画像アップロード | API実装済み | フロントエンド連携が不完全 |

---

## 3. 未実装機能一覧

### 🔴 高優先度 (Critical)

#### 3.1 決済機能
**現状**: DBスキーマ (`payments` テーブル) のみ存在  

**なぜ必要か**:
- 現在は注文はできるが、実際にお金を受け取る仕組みがない
- ユーザーが実際に商品を購入できるようにするため
- 店舗・配達員への支払い処理を自動化するため

**実装後にできること**:
- ✅ ユーザーがクレジットカードで決済できる
- ✅ 注文確定時に自動で決済処理が実行される
- ✅ 決済失敗時に適切なエラーメッセージを表示
- ✅ 返金処理ができる
- ✅ 決済履歴を確認できる

**実装手順**:

**Step 1: Stripe アカウントの準備**
1. [Stripe](https://stripe.com) でアカウント作成
2. テストモードのAPIキーを取得 (`sk_test_...`)
3. `backend/.env` に追加:
   ```
   STRIPE_SECRET_KEY=sk_test_xxxxxxxxx
   ```

**Step 2: バックエンドAPI実装** (`backend/app/routers/payments.py` を新規作成)
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import stripe
import os
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(prefix="/payments", tags=["payments"])
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

@router.post("/create-payment-intent")
async def create_payment_intent(
    order_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """決済インテントを作成"""
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Stripe決済インテント作成
    intent = stripe.PaymentIntent.create(
        amount=order.total_price,  # 円単位
        currency="jpy",
        metadata={"order_id": order_id}
    )
    
    # DB に記録
    payment = models.Payment(
        order_id=order_id,
        amount=order.total_price,
        payment_method="credit_card",
        payment_status="pending",
        transaction_id=intent.id
    )
    db.add(payment)
    db.commit()
    
    return {"client_secret": intent.client_secret}

@router.post("/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(database.get_db)):
    """Stripe Webhook (決済完了通知)"""
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, os.getenv("STRIPE_WEBHOOK_SECRET")
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
    # 決済成功
    if event["type"] == "payment_intent.succeeded":
        payment_intent = event["data"]["object"]
        order_id = payment_intent["metadata"]["order_id"]
        
        # 決済ステータスを更新
        payment = db.query(models.Payment).filter(
            models.Payment.transaction_id == payment_intent["id"]
        ).first()
        if payment:
            payment.payment_status = "completed"
            payment.paid_at = datetime.utcnow()
            
            # 注文ステータスも更新
            order = db.query(models.Order).filter(
                models.Order.id == order_id
            ).first()
            if order:
                order.status = "accepted"
            
            db.commit()
    
    return {"status": "success"}
```

**Step 3: フロントエンド実装** (`src/lib/services/payment_service.dart` を新規作成)
```dart
class PaymentService extends ApiService {
  Future<String> createPaymentIntent(int orderId) async {
    final response = await post('/payments/create-payment-intent', {
      'order_id': orderId,
    });
    return response['client_secret'];
  }
  
  Future<void> confirmPayment(String clientSecret) async {
    // Stripe Elements を使って決済確認
    // Web: stripe.js を使用
    // モバイル: stripe_flutter パッケージ使用
  }
}
```

**Step 4: 決済画面実装** (`src/lib/page/requester/c_payment.dart` を新規作成)
```dart
class CPaymentPage extends StatefulWidget {
  final int orderId;
  const CPaymentPage({required this.orderId});
}

class _CPaymentPageState extends State<CPaymentPage> {
  bool _isProcessing = false;
  
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    try {
      // 1. 決済インテント作成
      final clientSecret = await PaymentService().createPaymentIntent(widget.orderId);
      
      // 2. Stripe で決済処理
      await PaymentService().confirmPayment(clientSecret);
      
      // 3. 成功画面へ
      Navigator.pushReplacementNamed(context, '/order-success');
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('決済エラー'),
          content: Text('決済処理に失敗しました: $e'),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('お支払い')),
      body: Column(
        children: [
          // カード情報入力フォーム
          // Stripe Elements をここに埋め込む
          
          ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            child: _isProcessing 
                ? CircularProgressIndicator() 
                : Text('支払う'),
          ),
        ],
      ),
    );
  }
}
```

**Step 5: main.py にルーター追加**
```python
# backend/app/main.py
from .routers import payments  # 追加

app.include_router(payments.router)  # 追加
```

#### 3.2 リアルタイム配達追跡
**現状**: 画面UI (`c_order_tracking.dart`) は存在するが、リアルタイム更新なし  

**なぜ必要か**:
- 現在は画面を更新しないと配達状況がわからない
- ユーザーが「今どこにいるか」をリアルタイムで確認したい
- 配達員の位置を地図上で追跡したい

**実装後にできること**:
- ✅ 配達員の現在地が地図上にリアルタイム表示される
- ✅ 配達状況が変わると自動で画面が更新される
- ✅ 到着予想時刻が動的に計算される
- ✅ 配達員が近づくと通知が来る

**実装手順**:

**なぜ必要か**:
- 店舗や配達先の位置を視覚的に確認したい
- 配達員の現在地を地図上で追跡したい
- 距離に応じた配達料金を自動計算したい
- ルート案内を提供したい

**実装後にできること**:
- ✅ 店舗一覧で地図上に店舗位置が表示される
- ✅ 配達追跡で配達員の現在地が地図上に表示される
- ✅ 距離に基づいて配達料金が自動計算される
- ✅ 住所入力時に自動補完される
- ✅ 地図をクリックして配達先を選択できる

**なぜ必要か**:
- 現在は店舗がメニューを編集できない
- 商品の追加・価格変更・在庫管理ができない
- 商品画像を設定できない

**実装後にできること**:
- ✅ 店舗オーナーが自分で商品を追加・編集・削除できる
- ✅ 商品画像をアップロードできる
- ✅ カテゴリ分けができる（料理、デザート、ドリンクなど）
- ✅ 在庫切れ商品を自動的に非表示にできる
- ✅ 商品の表示順を変更できる

**実装手順**:

**Step 1: 商品管理画面の改善** (`src/lib/page/store/s_menu_edit.dart`)
```dart
class _SMenuEditPageState extends State<SMenuEditPage> {
  List<Product> _products = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ProductService().getMyStoreProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('商品の読み込みに失敗しました');
    }
  }
  
  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditDialog(mode: 'add'),
      ),
    );
    if (result == true) {
      _loadProducts(); // 再読み込み
    }
  }
  
  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductEditDialog(
          mode: 'edit',
          product: product,
        ),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }
  
  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('確認'),
        content: Text('この商品を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ProductService().deleteProduct(productId);
        _loadProducts();
        _showSuccess('商品を削除しました');
      } catch (e) {
        _showError('削除に失敗しました');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('メニュー管理')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: product.imageUrl != null
            ? Image.network(product.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
            : Container(width: 60, height: 60, color: Colors.grey[300]),
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¥${product.price}'),
            Text(
              product.isAvailable ? '販売中' : '販売停止',
              style: TextStyle(
                color: product.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editProduct(product),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(product.id),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: 商品追加・編集ダイアログ** (`src/lib/widgets/product_edit_dialog.dart` を新規作成)
```dart
class ProductEditDialog extends StatefulWidget {
  final String mode; // 'add' or 'edit'
  final Product? product;
  
  const ProductEditDialog({
    Key? key,
    required this.mode,
    this.product,
  }) : super(key: key);

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String? _imageUrl;
  bool _isAvailable = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '0');
    _imageUrl = widget.product?.imageUrl;
    _isAvailable = widget.product?.isAvailable ?? true;
  }
  
  Future<void> _pickImage() async {
    // 画像選択
    final result = await ImagePickerService().pickImage();
    if (result != null) {
      // 画像アップロード
      final url = await ImageUploadService().uploadProductImage(result);
      setState(() => _imageUrl = url);
    }
  }
  
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': int.parse(_priceController.text),
        'stock_quantity': int.parse(_stockController.text),
        'is_available': _isAvailable,
        'image_url': _imageUrl,
      };
      
      if (widget.mode == 'add') {
        await ProductService().createProduct(data);
      } else {
        await ProductService().updateProduct(widget.product!.id, data);
      }
      
      Navigator.pop(context, true); // 成功
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'add' ? '商品を追加' : '商品を編集'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // 画像
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageUrl != null
                    ? Image.network(_imageUrl!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50),
                          Text('画像を選択'),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16),
            
            // 商品名
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '商品名'),
              validator: (v) => v!.isEmpty ? '商品名を入力してください' : null,
            ),
            
            // 説明
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '説明'),
              maxLines: 3,
            ),
            
            // 価格
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: '価格（円）'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return '価格を入力してください';
                if (int.tryParse(v) == null) return '数字を入力してください';
                return null;
              },
            ),
            
            // 在庫数
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(labelText: '在庫数'),
              keyboardType: TextInputType.number,
            ),
            
            // 販売中/停止
            SwitchListTile(
              title: Text('販売中'),
              value: _isAvailable,
              onChanged: (v) => setState(() => _isAvailable = v),
            ),
            
            SizedBox(height: 24),
            
            // 保存ボタン
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? CircularProgressIndicator()
                  : Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: 商品サービスの完成** (`src/lib/services/product_service.dart`)
```dart
class ProductService extends ApiService {
  Future<List<Product>> getMyStoreProducts() async {
    final response = await get('/products/my/all');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }
  
  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await post('/products/', data);
    return Product.fromJson(response);
  }
  
  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await put('/products/$id', data);
    return Product.fromJson(response);
  }
  
  Future<void> deleteProduct(int id) async {
    await delete('/products/$id');
  }
}
```

**Step 4: バックエンドAPIの追加** (`backend/app/routers/products.py` に追加)
```python
@router.get("/my/all", response_model=List[schemas.Product])
def get_my_store_all_products(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """自分の店舗の全商品を取得"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Store only")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    
    products = db.query(models.Product).filter(
        models.Product.store_id == store.id
    ).order_by(models.Product.display_order).all()
    
    return products
```e Matrix API
5. 「認証情報」→「APIキーを作成」
6. APIキーをコピー: `AIzaSyXXXXXXXXXXXXXXXXXX`
7. **重要**: 使用量制限を設定 (1日$10など)

**Step 2: 環境変数に設定**
```yaml
# src/web/index.html に追加
<head>
  <!-- 既存のコード -->
  
  <!-- Google Maps -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
</head>
```

```dart
// src/lib/config/env_config.dart に追加
class EnvConfig {
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyXXXXXXXXXXXXXXXXXX',
  );
}
```

**Step 3: 地図ウィジェット実装** (`src/lib/widgets/map_widget.dart` を改善)
```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng? storePosition;      // 店舗位置
  final LatLng? deliveryPosition;   // 配達先位置
  final LatLng? delivererPosition;  // 配達員現在地
  final bool showRoute;             // ルート表示するか
  
  const MapWidget({
    Key? key,
    this.storePosition,
    this.deliveryPosition,
    this.delivererPosition,
    this.showRoute = false,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }
  
  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delivererPosition != widget.delivererPosition) {
      _updateMarkers();
    }
  }
  
  void _updateMarkers() {
    _markers.clear();
    
    // 店舗マーカー
    if (widget.storePosition != null) {
      _markers.add(Marker(
        markerId: MarkerId('store'),
        position: widget.storePosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: '店舗'),
      ));
    }
    
    // 配達先マーカー
    if (widget.deliveryPosition != null) {
      _markers.add(Marker(
        markerId: MarkerId('delivery'),
        position: widget.deliveryPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: '配達先'),
      ));
    }
    
    // 配達員マーカー
    if (widget.delivererPosition != null) {
      _markers.add(Marker(
        markerId: MarkerId('deliverer'),
        position: widget.delivererPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: '配達員'),
      ));
    }
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    // 初期カメラ位置（高知工科大学）
    final initialPosition = widget.storePosition ?? 
                           LatLng(33.5536, 133.6811);
    
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        _controller = controller;
        _fitBounds();
      },
    );
  }
  
  void _fitBounds() {
    // すべてのマーカーが表示されるようにカメラ調整
    if (_markers.isEmpty || _controller == null) return;
    
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (var marker in _markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }
    
    _controller!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      50, // padding
    ));
  }
}
```

**Step 4: 距離・料金計算サービス** (`src/lib/services/location_service.dart` に追加)
```dart
class LocationService extends ApiService {
  // Geocoding: 住所 → 座標
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    final response = await get('/locations/geocode?address=$address');
    return LatLng(
      response['latitude'],
      response['longitude'],
    );
  }
  
  // Distance Matrix: 距離と時間を計算
  Future<Map<String, dynamic>> calculateDistanceAndFee({
    required LatLng from,
    required LatLng to,
  }) async {
    final response = await post('/locations/calculate-distance', {
      'from_lat': from.latitude,
      'from_lng': from.longitude,
      'to_lat': to.latitude,
      'to_lng': to.longitude,
    });
    
    return {
      'distance_km': response['distance_km'],
      'duration_min': response['duration_min'],
      'delivery_fee': response['delivery_fee'],
    };
  }
}
```

**Step 5: バックエンド距離計算API** (`backend/app/routers/locations.py` を新規作成)
```python
from fastapi import APIRouter, HTTPException
import googlemaps
import os

router = APIRouter(prefix="/locations", tags=["locations"])
gmaps = googlemaps.Client(key=os.getenv("GOOGLE_MAPS_API_KEY"))

@router.get("/geocode")
def geocode_address(address: str):
    """住所から座標を取得"""
    try:
        result = gmaps.geocode(address)
        if not result:
            raise HTTPException(status_code=404, detail="Address not found")
        
        location = result[0]['geometry']['location']
        return {
            "latitude": location['lat'],
            "longitude": location['lng'],
            "formatted_address": result[0]['formatted_address']
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/calculate-distance")
def calculate_distance(
    from_lat: float,
    from_lng: float,
    to_lat: float,
    to_lng: float
):
    """距離と配達料金を計算"""
    try:
        result = gmaps.distance_matrix(
            origins=[(from_lat, from_lng)],
            destinations=[(to_lat, to_lng)],
            mode="driving"
        )
        
        if result['rows'][0]['elements'][0]['status'] != 'OK':
            raise HTTPException(status_code=400, detail="Cannot calculate route")
        
        distance_m = result['rows'][0]['elements'][0]['distance']['value']
        duration_s = result['rows'][0]['elements'][0]['duration']['value']
        
        distance_km = distance_m / 1000
        duration_min = duration_s / 60
        
        # 配達料金計算 (例: 基本300円 + 1kmごとに50円)
        delivery_fee = 300 + int(distance_km * 50)
        
        return {
            "distance_km": round(distance_km, 2),
            "duration_min": round(duration_min, 0),
            "delivery_fee": delivery_fee
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Step 6: requirements.txt に追加**
```
googlemaps
```

**Step 7: pubspec.yaml に追加**
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  google_maps_flutter_web: ^0.5.0
```
    def __init__(self):
        # user_id -> WebSocket のマッピング
        self.active_connections: Dict[int, WebSocket] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        print(f"User {user_id} connected. Total: {len(self.active_connections)}")
    
    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
            print(f"User {user_id} disconnected")
    
    async def send_to_user(self, user_id: int, message: dict):
        """特定のユーザーにメッセージ送信"""
        if user_id in self.active_connections:
            try:
                await self.active_connections[user_id].send_text(json.dumps(message))
            except:
                self.disconnect(user_id)
    
    async def broadcast_to_order(self, order_id: int, message: dict, db):
        """注文に関係する全員に送信 (依頼者、店舗、配達員)"""
        order = db.query(models.Order).filter(models.Order.id == order_id).first()
        if not order:
            return
        
        # 依頼者に送信
        requester = db.query(models.RequesterProfile).filter(
            models.RequesterProfile.id == order.requester_id
        ).first()
        if requester:
            await self.send_to_user(requester.user_id, message)
        
        # 店舗に送信
        store = db.query(models.StoreProfile).filter(
            models.StoreProfile.id == order.store_id
        ).first()
        if store:
            await self.send_to_user(store.user_id, message)
        
        # 配達員に送信
        if order.deliverer_id:
            deliverer = db.query(models.DelivererProfile).filter(
                models.DelivererProfile.id == order.deliverer_id
            ).first()
            if deliverer:
                await self.send_to_user(deliverer.user_id, message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            # クライアントからのメッセージを受信
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # ここでメッセージタイプに応じて処理
            # 例: {"type": "ping"} -> {"type": "pong"}
            if message.get("type") == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))
                
    except WebSocketDisconnect:
        manager.disconnect(user_id)
```

**Step 2: 配達員位置更新API** (`backend/app/routers/delivery.py` に追加)
```python
from ..websocket import manager

@router.post("/update-location")
async def update_delivery_location(
    delivery_id: int,
    latitude: float,
    longitude: float,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """配達員が現在地を更新"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Deliverer only")
    
    delivery = db.query(models.Delivery).filter(
        models.Delivery.id == delivery_id
    ).first()
    if not delivery:
        raise HTTPException(status_code=404, detail="Delivery not found")
    
    # 現在地を更新
    delivery.current_latitude = latitude
    delivery.current_longitude = longitude
    
    # 履歴に記録
    history = models.DeliveryLocationHistory(
        delivery_id=delivery_id,
        latitude=latitude,
        longitude=longitude
    )
    db.add(history)
    db.commit()
    
    # WebSocketで全員に通知
    await manager.broadcast_to_order(
        order_id=delivery.order_id,
        message={
            "type": "location_update",
            "delivery_id": delivery_id,
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": datetime.utcnow().isoformat()
        },
        db=db
    )
    
    return {"status": "success"}
```

**Step 3: フロントエンド WebSocket接続** (`src/lib/services/websocket_service.dart` を新規作成)
```dart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onMessage;
  
  void connect(int userId) {
    final wsUrl = 'ws://localhost:8000/ws/$userId';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    // メッセージ受信
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        onMessage?.call(data);
      },
      onError: (error) {
        print('WebSocket error: $error');
        // 再接続処理
        Future.delayed(Duration(seconds: 3), () => connect(userId));
      },
      onDone: () {
        print('WebSocket closed');
        // 再接続処理
        Future.delayed(Duration(seconds: 3), () => connect(userId));
      },
    );
  }
  
  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
  }
}
```

**Step 4: 追跡画面の更新** (`src/lib/page/requester/c_order_tracking.dart` を改善)
```dart
class _COrderTrackingPageState extends State<COrderTrackingPage> {
  final WebSocketService _wsService = WebSocketService();
  double? _delivererLat;
  double? _delivererLng;
  
  @override
  void initState() {
    super.initState();
    
    // WebSocket接続
    final userId = context.read<UserRoleProvider>().userId;
    _wsService.connect(userId!);
    
    // メッセージ受信時の処理
    _wsService.onMessage = (message) {
      if (message['type'] == 'location_update') {
        setState(() {
          _delivererLat = message['latitude'];
          _delivererLng = message['longitude'];
        });
      } else if (message['type'] == 'status_update') {
        // ステータス更新
        setState(() {
          // 注文状態を更新
        });
      }
    };
  }
  
  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 地図表示
          Expanded(
            child: MapWidget(
              delivererPosition: _delivererLat != null 
                ? LatLng(_delivererLat!, _delivererLng!) 
                : null,
              storePosition: widget.storePosition,
              deliveryPosition: widget.deliveryPosition,
            ),
          ),
          
          // ステータス表示
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('配達員が移動中です'),
                if (_delivererLat != null)
                  Text('現在地: $_delivererLat, $_delivererLng'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 5: main.py に WebSocket ルーター追加**
```python
# backend/app/main.py
from . import websocket

app.include_router(websocket.router)
```

#### 3.3 Google Maps統合
**現状**: `GOOGLE_MAPS_SETUP.md` は存在するが、実装なし  
**必要な実装**:
- [ ] Google Maps API キーの設定
- [ ] 地図ウィジェット実装 (`widgets/map_widget.dart`)
  - 店舗・配達先の位置表示
  - 配達員の現在地表示
  - ルート表示
- [ ] 距離・所要時間の計算
  - Google Distance Matrix API 利用
  - 配達料金の自動計算
- [ ] 住所⇔座標変換 (Geocoding)

#### 3.4 店舗商品管理 (完全実装)
**現状**: UI (`s_menu_edit.dart`) のみ、データ連携なし  
**必要な実装**:
- [ ] フロントエンド
  - 商品一覧の取得・表示
  - 商品の追加・編集・削除
  - カテゴリ管理
  - 在庫管理機能
  - 商品画像のアップロード
- [ ] バックエンド
  - 商品CRUD APIの完全テスト
  - カテゴリ管理API
  - 在庫更新ロジック

#### 3.5 配達員の仕事管理
**現状**: 基本機能のみ実装  
**必要な実装**:
- [ ] 仕事の検索・フィルタリング
  - 距離順、報酬順でソート
  - 配達先エリアでフィルタ
- [ ] 配達ステータス管理の完全実装
  - ステータス遷移の検証
  - 各ステータスでの通知送信
- [ ] 配達完了処理
  - 写真撮影機能
  - 配達完了証明
  - 自動報酬計算

### 🟡 中優先度 (Important)

#### 3.6 レビュー・評価システム
**現状**: UI (`c_review.dart`) は存在、DB実装なし  
**必要な実装**:
- [ ] データベース設計
  - `reviews` テーブル作成
  - 店舗評価、配達員評価の分離
- [ ] バックエンド API
  - レビュー投稿API
  - レビュー取得API
  - 平均評価計算
- [ ] フロントエンド
  - レビュー投稿画面の完成
  - 星評価の表示・集計
  - レビュー一覧表示

#### 3.7 給与・売上管理
**現状**: DBスキーマのみ (`deliverer_payouts`, `store_sales`)  
**必要な実装**:
- [ ] 配達員給与計算
  - 期間別集計API
  - 配達件数・報酬の自動計算
  - 給与明細生成
  - 振込処理ワークフロー
- [ ] 店舗売上管理
  - 売上集計API
  - 手数料計算
  - 期間別レポート
  - CSV/PDFエクスポート
- [ ] フロントエンド画面
  - 配達員: `d_payslip.dart` の実装
  - 店舗: `s_sales.dart` の実装

#### 3.8 管理者ダッシュボード
**現状**: 未実装  
**必要な実装**:
- [ ] バックエンド
  - 管理者専用API (`routers/admin.py`)
  - ユーザー管理 (一覧・編集・停止)
  - 注文・配達の監視
  - システム統計データ取得
- [ ] フロントエンド
  - 管理者画面構築
  - ダッシュボード (KPI表示)
  - ユーザー管理画面
  - トラブル対応画面

#### 3.9 住所管理の完全実装
**現状**: 基本機能のみ (`c_address_management.dart`)  
**必要な実装**:
- [ ] 住所の追加・編集・削除の完全実装
- [ ] デフォルト住所の設定
- [ ] 住所入力の自動補完
- [ ] 郵便番号から住所検索
- [ ] 地図から住所選択

#### 3.10 プッシュ通知 (リアルタイム)
**現状**: ポーリングによる通知取得のみ  
**必要な実装**:
- [ ] WebSocket による双方向通信
  - `backend/app/websocket.py` 作成
  - 接続管理
  - ユーザー別チャンネル
- [ ] Firebase Cloud Messaging (FCM)
  - サーバー側トークン管理
  - プッシュ通知送信
- [ ] フロントエンド
  - WebSocket接続
  - FCMトークン登録
  - 通知受信処理

### 🟢 低優先度 (Enhancement)

#### 3.11 検索・フィルタ機能の強化
- [ ] 店舗検索
  - キーワード検索
  - カテゴリ、評価、距離でフィルタ
  - お気に入り機能
- [ ] 商品検索
  - 全文検索
  - 価格帯フィルタ
  - アレルギー情報対応

#### 3.12 クーポン・プロモーション
- [ ] クーポンシステム
  - クーポンコード管理
  - 割引計算
  - 使用履歴
- [ ] プロモーション通知
  - 特定ユーザーへのクーポン配布
  - 新規ユーザー特典

#### 3.13 多言語対応
- [ ] i18n実装
  - 日本語・英語
  - 言語切り替え機能
- [ ] 通貨対応

#### 3.14 アクセシビリティ
- [ ] スクリーンリーダー対応
- [ ] キーボード操作
- [ ] ダークモード

#### 3.15 パフォーマンス最適化
- [ ] 画像の遅延読み込み
- [ ] キャッシュ戦略
- [ ] ページネーション改善
- [ ] データベースインデックス最適化

#### 3.16 セキュリティ強化
- [ ] レート制限 (Rate Limiting)
- [ ] CSRF対策
- [ ] SQLインジェクション対策の再確認
- [ ] ログ監視

#### 3.17 テスト
- [ ] ユニットテスト
  - バックエンド: pytest
  - フロントエンド: flutter test
- [ ] 統合テスト
- [ ] E2Eテスト

---

## 4. 優先度別タスクリスト

### フェーズ1: MVP完成 (2-3週間)

#### Week 1: コア機能完成
**担当: メンバー全員**

- [ ] **決済機能** (担当: メンバーA)
  - 決済APIの実装
  - カード情報管理
  - 注文確定時の決済処理
  
- [ ] **Google Maps統合** (担当: メンバーB)
  - API キーの設定
  - 地図表示実装
  - 距離・料金計算
  
- [ ] **店舗商品管理** (担当: メンバーC)
  - 商品CRUD完全実装
  - 画像アップロード連携
  - 在庫管理
  
- [ ] **配達員仕事管理** (担当: メンバーD)
  - 仕事検索・フィルタ
  - ステータス管理強化
  - 完了処理実装

#### Week 2: リアルタイム機能
**担当: メンバー全員**

- [ ] **WebSocket実装** (担当: メンバーA & B)
  - バックエンド WebSocket エンドポイント
  - フロントエンド接続処理
  - 配達追跡のリアルタイム化
  
- [ ] **通知システム強化** (担当: メンバーC & D)
  - リアルタイム通知
  - 通知ルールの実装
  - 未読管理の改善

#### Week 3: 仕上げ
**担当: メンバー全員**

- [ ] **レビュー・評価システム** (担当: メンバーA)
  - DB設計・実装
  - API実装
  - UI完成
  
- [ ] **給与・売上管理** (担当: メンバーB)
  - 集計ロジック
  - レポート生成
  - 画面実装
  
- [ ] **バグ修正・テスト** (担当: 全員)
  - 結合テスト
  - ユーザビリティ改善
  - ドキュメント更新

### フェーズ2: 機能拡張 (2-3週間)

- 管理者ダッシュボード
- 検索・フィルタ強化
- クーポン・プロモーション
- パフォーマンス最適化

### フェーズ3: 品質向上 (継続的)

- テスト追加
- セキュリティ強化
- アクセシビリティ対応
- 多言語対応

---

## 5. チーム分担案

### メンバーA: 決済・レビュー担当
**専門**: バックエンド API開発

**主な担当機能**:
- 決済システム (Stripe連携)
- レビュー・評価システム
- WebSocket (サーバー側)
- APIドキュメント整備

**担当ファイル**:
- `backend/app/routers/payments.py` (新規作成)
- `backend/app/routers/reviews.py` (新規作成)
- `backend/app/websocket.py` (新規作成)
- `backend/app/models.py` (テーブル追加)

### メンバーB: 地図・位置情報担当
**専門**: フロントエンド + 外部API連携

**主な担当機能**:
- Google Maps統合
- 配達追跡 (リアルタイム)
- 位置情報サービス
- 給与・売上管理

**担当ファイル**:
- `src/lib/widgets/map_widget.dart` (改善)
- `src/lib/services/location_service.dart` (改善)
- `src/lib/page/requester/c_order_tracking.dart` (改善)
- `src/lib/page/deliverer/d_map.dart` (改善)
- `src/lib/page/deliverer/d_payslip.dart` (実装)
- `src/lib/page/store/s_sales.dart` (実装)

### メンバーC: 店舗管理担当
**専門**: フルスタック

**主な担当機能**:
- 店舗商品管理 (完全実装)
- 在庫管理
- カテゴリ管理
- 画像アップロード連携
- 通知システム強化

**担当ファイル**:
- `src/lib/page/store/s_menu_edit.dart` (改善)
- `src/lib/page/store/s_inventory_status.dart` (実装)
- `backend/app/routers/products.py` (改善)
- `src/lib/services/image_upload_service.dart` (改善)
- `src/lib/provider/notification_provider.dart` (改善)

### メンバーD: 配達員機能担当
**専門**: フロントエンド + ワークフロー

**主な担当機能**:
- 配達員仕事管理
- 配達ステータス管理
- 配達履歴
- 住所管理の完全実装

**担当ファイル**:
- `src/lib/page/deliverer/d_job_select.dart` (改善)
- `src/lib/page/deliverer/d_delivery_history.dart` (実装)
- `src/lib/page/requester/c_address_management.dart` (改善)
- `backend/app/routers/delivery.py` (改善)
- `src/lib/provider/delivery_provider.dart` (改善)

---

## 6. 技術的課題と解決方針

### 課題1: リアルタイム通信の実装
**課題**:
- 現在はポーリングで通知を取得 (非効率)
- 配達追跡のリアルタイム更新が未実装

**解決方針**:
1. WebSocket実装
   - FastAPI の `websockets` ライブラリ使用
   - 接続プール管理
   - 切断時の再接続処理
2. フロントエンド
   - `web_socket_channel` パッケージ使用
   - 自動再接続ロジック
   - エラーハンドリング

**参考コード例**:
```python
# backend/app/websocket.py
from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[int, WebSocket] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        self.active_connections[user_id] = websocket
    
    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            await self.active_connections[user_id].send_text(message)

manager = ConnectionManager()

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # 処理
    except WebSocketDisconnect:
        manager.disconnect(user_id)
```

### 課題2: Google Maps API の料金
**課題**:
- 開発・テスト時に予想外の課金が発生する可能性

**解決方針**:
1. Google Cloud Console で使用量制限を設定
2. 開発環境では固定座標を使用
3. 本番環境のみ実際のAPIを呼び出す

```dart
// config/env_config.dart
class EnvConfig {
  static const bool useRealMapsApi = bool.fromEnvironment(
    'USE_REAL_MAPS',
    defaultValue: false,
  );
}
```

### 課題3: 決済のセキュリティ
**課題**:
- クレジットカード情報の取り扱い
- PCI DSS準拠

**解決方針**:
1. カード情報を直接保存しない
2. Stripe等の外部サービスを利用
   - トークン化されたデータのみ保存
   - 決済処理は外部APIに委譲
3. HTTPS必須
4. ログにカード情報を出力しない

### 課題4: パフォーマンス (大量データ)
**課題**:
- 注文・商品データが増えると遅延
- 画像読み込みの負荷

**解決方針**:
1. ページネーション実装
   - API: `skip` / `limit` パラメータ
   - フロントエンド: 無限スクロール
2. 画像最適化
   - サーバー側でリサイズ
   - WebP形式へ変換
   - CDN利用
3. データベースクエリ最適化
   - インデックス追加
   - N+1問題の解消
   - 不要なJOINの削減

### 課題5: エラーハンドリングの統一
**課題**:
- エラー処理が各所でバラバラ
- ユーザーへのエラーメッセージが不親切

**解決方針**:
1. バックエンド
   - カスタム例外クラス作成
   - グローバルエラーハンドラー
   - ステータスコードの統一
2. フロントエンド
   - 統一エラーダイアログ
   - エラーメッセージの日本語化
   - リトライ機能

---

## 7. 開発環境とツール

### 必須ツール
- **Docker Desktop** (Windows/Mac)
- **VS Code** + 推奨拡張機能:
  - Flutter
  - Python
  - Docker
  - PostgreSQL (Database Client)

### 推奨ツール
- **Postman** / **Thunder Client**: API テスト
- **DBeaver** / **pgAdmin**: データベース管理
- **Git** + **GitHub/GitLab**: バージョン管理

### 環境変数設定
```powershell
# .env ファイル (backend/)
DATABASE_URL=postgresql://student:password123@db:5432/university_app
SECRET_KEY=your-secret-key-change-in-production
STRIPE_SECRET_KEY=sk_test_xxxxx
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXX
```

### コマンド集

#### 起動・停止
```powershell
# 起動
docker-compose up --build -d

# ログ確認
docker-compose logs -f backend
docker-compose logs -f flutter

# 停止
docker-compose down

# DB初期化 (注意: データが消えます)
docker-compose down -v
docker-compose up --build -d
```

#### 開発時
```powershell
# バックエンドコンテナに入る
docker exec -it fastapi_backend bash

# DBに直接接続
docker exec -it postgres_db psql -U student -d university_app

# Flutterコンテナに入る
docker exec -it flutter_dev bash
```

---

## 8. 品質管理

### コーディング規約

#### Python (Backend)
- **スタイル**: PEP 8
- **フォーマッター**: `black`
- **リンター**: `flake8`, `pylint`
- **型ヒント**: 可能な限り使用

```python
# 良い例
def create_order(
    order: schemas.OrderCreate,
    current_user: models.User,
    db: Session
) -> schemas.Order:
    """注文を作成する"""
    pass
```

#### Dart (Frontend)
- **スタイル**: Dart公式スタイルガイド
- **フォーマッター**: `dart format`
- **リンター**: `analysis_options.yaml` で設定
- **命名規則**:
  - クラス: `PascalCase`
  - 変数・関数: `camelCase`
  - ファイル: `snake_case.dart`

```dart
// 良い例
class OrderService {
  Future<List<Order>> fetchMyOrders() async {
    // ...
  }
}
```

### Git運用

#### ブランチ戦略
```
main (本番)
  ├── develop (開発)
  │   ├── feature/payment-system (機能開発)
  │   ├── feature/google-maps (機能開発)
  │   ├── bugfix/order-status (バグ修正)
  │   └── ...
```

#### コミットメッセージ
```
[種類] 簡潔な説明

詳細説明 (オプション)

# 種類:
# feat: 新機能
# fix: バグ修正
# refactor: リファクタリング
# docs: ドキュメント
# test: テスト追加
# style: コードスタイル修正

例:
[feat] 決済API実装
[fix] 注文ステータス更新のバグ修正
[refactor] 商品取得処理を最適化
```

### レビュー基準
- [ ] コーディング規約に準拠
- [ ] 適切なエラーハンドリング
- [ ] 型安全性 (型ヒント・型チェック)
- [ ] コメント・ドキュメント
- [ ] テストの追加/更新
- [ ] パフォーマンスへの配慮

### テスト方針

#### ユニットテスト
- **バックエンド**: `pytest` でAPIテスト
- **フロントエンド**: `flutter test` でウィジェットテスト

#### 統合テスト
- エンドポイント間の連携テスト
- データフロー全体のテスト

#### E2Eテスト (後回し可)
- ユーザーシナリオベースのテスト

---

## 9. 注意事項・ベストプラクティス

### セキュリティ
1. **環境変数の管理**
   - API キー、パスワードは `.env` ファイルで管理
   - `.env` を `.gitignore` に追加 (コミットしない)
   
2. **認証・認可**
   - JWTトークンの有効期限を適切に設定
   - パスワードは必ずハッシュ化 (bcrypt)
   
3. **SQLインジェクション対策**
   - SQLAlchemy ORM を使用 (生SQLは避ける)
   - ユーザー入力を直接クエリに埋め込まない

### パフォーマンス
1. **N+1問題の回避**
   - SQLAlchemy の `joinedload()` を使用
   
2. **キャッシュの活用**
   - よく使うデータはメモリキャッシュ
   
3. **画像の最適化**
   - サーバー側でリサイズ
   - 適切なフォーマット (WebP)

### UX/UI
1. **ローディング表示**
   - API呼び出し中は必ずローディング表示
   
2. **エラーメッセージ**
   - ユーザーフレンドリーな日本語メッセージ
   - リトライ可能な操作は「再試行」ボタン
   
3. **レスポンシブデザイン**
   - モバイル・タブレット・デスクトップ対応

---

## 10. よくある質問 (FAQ)

### Q1: データベースを初期化したい
```powershell
docker-compose down -v
docker-compose up --build -d
```

### Q2: APIがCORSエラーになる
`backend/app/main.py` の CORS設定を確認:
```python
origins = [
    "http://localhost:8080",
    "*"  # 開発時のみ
]
```

### Q3: Flutterの画面が更新されない
```powershell
# コンテナ内で
flutter clean
flutter pub get
```

### Q4: パスワードのハッシュを生成したい
```powershell
docker exec fastapi_backend python -c "
from passlib.context import CryptContext
pwd = CryptContext(schemes=['bcrypt'], deprecated='auto')
print(pwd.hash('your_password'))
"
```

### Q5: どのAPIエンドポイントがあるか確認したい
ブラウザで http://localhost:8000/docs を開く (Swagger UI)

---

## 11. まとめ

### 短期目標 (2-3週間)
1. **MVP完成**: 注文〜配達の基本フローが動作
2. **リアルタイム機能**: 配達追跡、通知
3. **決済機能**: テスト決済まで実装

### 中期目標 (1-2ヶ月)
1. **管理機能**: 給与・売上管理、管理者ダッシュボード
2. **評価システム**: レビュー・評価の完全実装
3. **検索・フィルタ**: ユーザビリティ向上

### 長期目標 (3ヶ月以降)
1. **本番リリース準備**: セキュリティ、パフォーマンス最適化
2. **拡張機能**: クーポン、多言語、モバイルアプリ
3. **運用体制**: 監視、ログ、バックアップ

---

## 12. 参考資料

### ドキュメント
- [README.md](../README.md) - 環境構築・基本操作
- [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) - Google Maps設定

### 外部リソース
- [FastAPI 公式](https://fastapi.tiangolo.com/)
- [Flutter 公式](https://docs.flutter.dev/)
- [Stripe API](https://stripe.com/docs/api)
- [Google Maps API](https://developers.google.com/maps)

---

**更新履歴**:
- 2026/01/13: 初版作成

**問い合わせ**: 不明点があればチームで相談してください
