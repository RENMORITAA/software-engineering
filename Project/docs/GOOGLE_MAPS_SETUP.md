# Google Maps API 設定ガイド

このドキュメントでは、Google Maps APIをFlutter Webアプリで使用するための設定方法を説明します。

## 1. Google Cloud Console でAPIキーを取得

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクトを作成または選択
3. **APIs & Services** > **Library** に移動
4. 以下のAPIを有効化:
   - **Maps JavaScript API** (Web用)
   - **Geocoding API** (住所から座標への変換)
   - **Directions API** (経路検索) ※オプション

5. **APIs & Services** > **Credentials** に移動
6. **Create Credentials** > **API Key** をクリック
7. APIキーを安全な場所に保存

## 2. APIキーの制限設定（推奨）

セキュリティのため、APIキーを制限することを推奨します:

1. 作成したAPIキーの **Edit** をクリック
2. **Application restrictions** で:
   - **HTTP referrers** を選択
   - 許可するドメインを追加（例: `localhost:*`, `yourdomain.com/*`）
3. **API restrictions** で:
   - 使用するAPIのみを選択

## 3. Flutter Web への設定

### web/index.html の編集

`src/web/index.html` ファイルの `<head>` セクションに以下を追加:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

`YOUR_API_KEY` を実際のAPIキーに置き換えてください。

### 環境変数での管理（推奨）

本番環境では、APIキーを直接コードに書かず、環境変数で管理することを推奨します:

```html
<script>
  // ビルド時に環境変数から注入
  window.GOOGLE_MAPS_API_KEY = "{{GOOGLE_MAPS_API_KEY}}";
</script>
```

## 4. パッケージの確認

`pubspec.yaml` に以下のパッケージが含まれていることを確認:

```yaml
dependencies:
  google_maps_flutter: ^2.10.0
  google_maps_flutter_web: ^0.5.10
  geolocator: ^13.0.2
  geolocator_web: ^4.1.1
```

## 5. 実際のGoogle Mapsウィジェットへの移行

現在はモック地図表示を使用しています。実際のGoogle Mapsに移行するには:

### map_widget.dart の修正

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  // ... 既存のプロパティ

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.initialLatitude ?? 33.5944,
          widget.initialLongitude ?? 133.8628,
        ),
        zoom: widget.initialZoom,
      ),
      markers: _buildMarkers(),
      polylines: widget.showRoute ? _buildPolylines() : {},
      myLocationEnabled: widget.showCurrentLocation,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) {
        _controller = controller;
      },
      onTap: (latLng) {
        widget.onMapTap?.call(latLng.latitude, latLng.longitude);
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    
    if (widget.showDestination && 
        widget.destinationLatitude != null && 
        widget.destinationLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.destinationLatitude!,
            widget.destinationLongitude!,
          ),
          infoWindow: const InfoWindow(title: '目的地'),
        ),
      );
    }
    
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) {
      return {};
    }
    
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routePoints!
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        color: Colors.blue,
        width: 4,
      ),
    };
  }
}
```

## 6. 位置情報の権限設定

### Web

ブラウザが自動的に位置情報の許可を求めます。

### Android (将来的な対応)

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (将来的な対応)

`ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>配達位置を追跡するために位置情報を使用します</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>バックグラウンドで配達位置を追跡するために位置情報を使用します</string>
```

## 7. 料金について

Google Maps Platform は従量課金制です:

- 月額 $200 のクレジットが無料
- Maps JavaScript API: 1000回のロードで $7
- Geocoding API: 1000回で $5

詳細: [Google Maps Platform Pricing](https://cloud.google.com/maps-platform/pricing)

## 8. トラブルシューティング

### 地図が表示されない

1. APIキーが正しいか確認
2. 必要なAPIが有効化されているか確認
3. ブラウザのコンソールでエラーを確認
4. APIキーの制限設定が正しいか確認

### 位置情報が取得できない

1. ブラウザで位置情報の許可を確認
2. HTTPSで配信されているか確認（localhostは例外）
3. geolocatorパッケージのバージョンを確認
