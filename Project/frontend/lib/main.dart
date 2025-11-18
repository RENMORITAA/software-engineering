import 'package:flutter/material.dart';

void main() {
  runApp(const StellarDeliveryApp());
}

class StellarDeliveryApp extends StatelessWidget {
  const StellarDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StellarHomePage(),
    );
  }
}

class StellarHomePage extends StatelessWidget {
  const StellarHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNav(),
      body: Column(
        children: [
          _headerImage(context),
          _storeInfo(),
          const SizedBox(height: 12),
          _bottomInfoButtons(),
        ],
      ),
    );
  }

  // -------------------------------
  // 上部の背景 + 店舗画像
  // -------------------------------
  Widget _headerImage(BuildContext context) {
    return Stack(
      children: [
        // 背景宇宙柄
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/space_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 店舗写真
        Container(
          margin: const EdgeInsets.only(top: 60),
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/food_sample.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black38,
                BlendMode.darken,
              ),
            ),
          ),
        ),
        // 閉じるボタン
        Positioned(
          top: 20,
          left: 20,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.black54,
            child: Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ),
        // テキスト「ようこそステラ食堂へ」
        const Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Center(
            child: Text(
              "ようこそ\nステラ食堂へ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 6,
                      color: Colors.black87)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // -------------------------------
  // 店舗情報欄
  // -------------------------------
  Widget _storeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: const [
          Text(
            "ステラ食堂 STELLAR\nDINING ROOM",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "5.0★",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "基本料金 ¥150\nユーザーサービス料金 ¥70",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 20),
              SizedBox(width: 4),
              Text("店舗からの距離 2.0 km\n高知県香美市土佐山田町〇〇〇"),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // 2つの四角ボタン「手数料」「到着時間」
  // -------------------------------
  Widget _bottomInfoButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                children: [
                  Text("合計手数料", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 6),
                  Text("¥320",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                children: [
                  Text("到着予定時間", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 6),
                  Text("20分",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // 下部のナビバー
  // -------------------------------
  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "",
        ),
      ],
    );
  }
}
