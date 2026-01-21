/**
 * Stellar Delivery - Leaflet地図制御スクリプト
 * 店舗から依頼者へのルート表示 + 配達員アニメーション
 */

// グローバルマップオブジェクトを保存
const deliveryMaps = {};

// Leafletライブラリがロード済みか確認
function waitForLeaflet(callback) {
  if (typeof L !== 'undefined') {
    console.log('[waitForLeaflet] Leaflet is ready!');
    callback();
  } else {
    console.log('[waitForLeaflet] Waiting for Leaflet...');
    setTimeout(() => waitForLeaflet(callback), 100);
  }
}

// メッセージリスナーを設定
window.addEventListener('message', function(event) {
  const data = event.data;
  console.log('[delivery_map.js] Received message:', data);
  
  if (data.type === 'initMap') {
    console.log('[delivery_map.js] Initializing map with config:', data);
    waitForLeaflet(() => initDeliveryMap(data));
  } else if (data.type === 'updateDeliverer') {
    console.log('[delivery_map.js] Updating deliverer position:', data);
    updateDelivererPosition(data);
  }
});

// ページロード完了時にLeafletの状態を確認
window.addEventListener('DOMContentLoaded', function() {
  console.log('[delivery_map.js] DOMContentLoaded - Leaflet available:', typeof L !== 'undefined');
});

window.addEventListener('load', function() {
  console.log('[delivery_map.js] Window loaded - Leaflet available:', typeof L !== 'undefined');
  if (typeof L === 'undefined') {
    console.error('[delivery_map.js] WARNING: Leaflet library not loaded!');
  }
});

/**
 * 配達マップを初期化
 */
function initDeliveryMap(config) {
  const { mapId, startLat, startLng, destLat, destLng, zoom, showRoute } = config;
  
  console.log('[initDeliveryMap] Starting initialization for mapId:', mapId);
  console.log('[initDeliveryMap] Checking if element exists:', document.getElementById(mapId));
  
  // 既存のマップがあれば削除
  if (deliveryMaps[mapId]) {
    console.log('[initDeliveryMap] Removing existing map');
    deliveryMaps[mapId].map.remove();
  }

  // DOM要素が存在するか確認
  const mapElement = document.getElementById(mapId);
  if (!mapElement) {
    console.error('[initDeliveryMap] Map element not found! mapId:', mapId);
    // リトライ
    setTimeout(() => {
      console.log('[initDeliveryMap] Retrying...');
      initDeliveryMap(config);
    }, 500);
    return;
  }

  console.log('[initDeliveryMap] Creating Leaflet map...');
  
  // Leaflet地図を作成
  const map = L.map(mapId, {
    center: [startLat, startLng],
    zoom: zoom || 13,
    zoomControl: true,
  });

  console.log('[initDeliveryMap] Map created successfully');

  // OpenStreetMapタイルを追加
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19,
    minZoom: 3
  }).addTo(map);

  // 店舗マーカー（スタート地点）
  const storeIcon = L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        background: #4CAF50;
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 20px;
        border: 3px solid white;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      ">🏪</div>
    `,
    iconSize: [40, 40],
    iconAnchor: [20, 20]
  });
  const storeMarker = L.marker([startLat, startLng], { icon: storeIcon }).addTo(map);
  storeMarker.bindPopup('<b>🏪 店舗（出発点）</b><br>配達開始地点');

  // 配達員マーカー（動くマーカー）
  const delivererIcon = L.divIcon({
    className: 'deliverer-marker',
    html: `
      <div style="
        background: #2196F3;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 24px;
        border: 4px solid white;
        box-shadow: 0 4px 12px rgba(33, 150, 243, 0.5);
        animation: pulse 2s infinite;
      ">🚗</div>
      <style>
        @keyframes pulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.1); }
        }
      </style>
    `,
    iconSize: [50, 50],
    iconAnchor: [25, 25]
  });
  const delivererMarker = L.marker([startLat, startLng], { icon: delivererIcon }).addTo(map);
  delivererMarker.bindPopup('<b>🚗 配達員</b><br>現在配達中');

  // マップオブジェクトを保存
  deliveryMaps[mapId] = {
    map: map,
    storeMarker: storeMarker,
    delivererMarker: delivererMarker,
    routePolyline: null,
    destinationMarker: null
  };

  // ルート表示が必要な場合
  if (showRoute && destLat && destLng) {
    // 依頼者マーカー（ゴール地点）
    const customerIcon = L.divIcon({
      className: 'custom-marker',
      html: `
        <div style="
          background: #f44336;
          width: 40px;
          height: 40px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 20px;
          border: 3px solid white;
          box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        ">🏁</div>
      `,
      iconSize: [40, 40],
      iconAnchor: [20, 20]
    });
    const customerMarker = L.marker([destLat, destLng], { icon: customerIcon }).addTo(map);
    customerMarker.bindPopup('<b>🏁 配達先（依頼者）</b><br>配達目的地');
    deliveryMaps[mapId].destinationMarker = customerMarker;

    // OSRMでルートを取得
    fetchRoute(mapId, startLat, startLng, destLat, destLng, map);
  }
}

/**
 * OSRMからルート情報を取得して描画
 */
async function fetchRoute(mapId, startLat, startLng, endLat, endLng, map) {
  try {
    // OSRM API（徒歩ルート）
    // プロファイル: foot-walking（徒歩）、driving（車）、bike（自転車）
    const url = `https://router.project-osrm.org/route/v1/driving/${startLng},${startLat};${endLng},${endLat}?overview=full&geometries=geojson`;
    
    const response = await fetch(url);
    if (!response.ok) throw new Error('ルート取得失敗');
    
    const data = await response.json();
    if (!data.routes || data.routes.length === 0) {
      console.error('ルートが見つかりません');
      return;
    }

    const route = data.routes[0];
    const coordinates = route.geometry.coordinates;

    // GeoJSON形式の座標をLeaflet用に変換（[経度, 緯度] → [緯度, 経度]）
    const latlngs = coordinates.map(coord => [coord[1], coord[0]]);

    // ルートをポリラインで描画
    const routePolyline = L.polyline(latlngs, {
      color: '#667eea',
      weight: 6,
      opacity: 0.8,
      lineJoin: 'round',
      lineCap: 'round'
    }).addTo(map);

    deliveryMaps[mapId].routePolyline = routePolyline;

    // 地図の表示範囲を調整
    map.fitBounds(routePolyline.getBounds(), { padding: [50, 50] });

    // ルート情報をFlutterに送信
    const distanceKm = (route.distance / 1000).toFixed(2);
    const durationMin = Math.round(route.duration / 60);
    
    console.log(`ルート情報: ${distanceKm} km, ${durationMin} 分`);
    
    // Flutterへの通知（postMessage経由）
    window.parent.postMessage({
      type: 'routeCalculated',
      mapId: mapId,
      distanceKm: parseFloat(distanceKm),
      durationMin: durationMin
    }, '*');

  } catch (error) {
    console.error('ルート取得エラー:', error);
  }
}

/**
 * 配達員の位置を更新（アニメーション）
 */
function updateDelivererPosition(config) {
  const { mapId, lat, lng } = config;
  const mapObj = deliveryMaps[mapId];
  
  if (!mapObj || !mapObj.delivererMarker) return;

  // マーカーの位置を滑らかに移動
  const currentPos = mapObj.delivererMarker.getLatLng();
  const newPos = L.latLng(lat, lng);

  // アニメーション（1秒かけて移動）
  animateMarker(mapObj.delivererMarker, currentPos, newPos, 1000);

  // 地図の中心を配達員に追従
  mapObj.map.panTo(newPos, { animate: true, duration: 1 });
}

/**
 * マーカーをアニメーションで移動
 */
function animateMarker(marker, startPos, endPos, duration) {
  const startTime = Date.now();
  
  function update() {
    const elapsed = Date.now() - startTime;
    const progress = Math.min(elapsed / duration, 1);
    
    // 線形補間で位置を計算
    const lat = startPos.lat + (endPos.lat - startPos.lat) * progress;
    const lng = startPos.lng + (endPos.lng - startPos.lng) * progress;
    
    marker.setLatLng([lat, lng]);
    
    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }
  
  update();
}

// デバッグ用：コンソールログ
console.log('Stellar Delivery Map Script Loaded');
