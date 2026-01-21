import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import 'c_product_list.dart';
import 'c_notification.dart'; // 通知画面をインポート

class CHomePage extends StatefulWidget {
  const CHomePage({super.key});

  @override
  State<CHomePage> createState() => _CHomePageState();
}

class _CHomePageState extends State<CHomePage> {
  // 状態管理用の変数
  String _searchQuery = '';
  String _selectedCategory = 'すべて';

  @override
  void initState() {
    super.initState();
    // 画面表示時に店舗データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final userProvider = context.watch<UserRoleProvider>();
    
    // --- フィルタリングロジック ---
    final filteredStores = storeProvider.stores.where((store) {
      final name = (store['store_name'] ?? '').toString().toLowerCase();
      final desc = (store['description'] ?? '').toString().toLowerCase();
      
      // 検索ワードに一致するか
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || 
                            desc.contains(_searchQuery.toLowerCase());
      
      // カテゴリに一致するか
      // ※簡易的に名前や説明にカテゴリ名が含まれているかで判定
      final matchesCategory = _selectedCategory == 'すべて' || 
                              name.contains(_selectedCategory) || 
                              desc.contains(_selectedCategory);
      
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => storeProvider.fetchStores(),
          child: CustomScrollView(
            slivers: [
              // 1. ヘッダー (名前・通知・住所)
              SliverToBoxAdapter(
                child: _buildDynamicHeader(context, userProvider.userName ?? 'ゲスト'),
              ),

              // 2. 検索バー
              SliverToBoxAdapter(child: _buildActiveSearchBar()),

              // 3. カテゴリ (タップでフィルタリング)
              SliverToBoxAdapter(child: _buildCategorySection()),

              // 4. おすすめ店舗 見出し
              SliverToBoxAdapter(child: _buildSectionHeader('おすすめ店舗')),

              // 5. 店舗リスト
              storeProvider.isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : filteredStores.isEmpty
                      ? _buildEmptyState()
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildStoreCard(filteredStores[index]),
                            childCount: filteredStores.length,
                          ),
                        ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }

  // --- 動的ヘッダー (通知画面への遷移を追加) ---
  Widget _buildDynamicHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('こんにちは', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 4),
                  Text('$name さん', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              IconButton(
                onPressed: () {
                  // 通知画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CNotificationPage()),
                  );
                },
                icon: const Badge(
                  label: Text('3'), // 未読数
                  backgroundColor: Colors.red,
                  child: Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAddressSelector(),
        ],
      ),
    );
  }

  // --- 住所セレクター ---
  Widget _buildAddressSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('配達先', style: TextStyle(fontSize: 11, color: Colors.white70)),
                Text('高知県香美市土佐山田町...', 
                  style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500), 
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () { /* 住所変更画面へ */ },
            child: const Text('変更', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 検索バー ---
  Widget _buildActiveSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: '店舗・商品を検索',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // --- カテゴリセクション ---
  Widget _buildCategorySection() {
    final categories = [
      {'label': 'すべて', 'icon': Icons.all_inclusive, 'color': Colors.blue},
      {'label': '和食', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'label': 'カフェ', 'icon': Icons.local_cafe, 'color': Colors.brown},
      {'label': 'ファストフード', 'icon': Icons.fastfood, 'color': Colors.red},
      {'label': 'ラーメン', 'icon': Icons.ramen_dining, 'color': Colors.amber},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('カテゴリ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = _selectedCategory == cat['label'];
                final catColor = cat['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label'] as String),
                    child: Column(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? catColor : catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                          child: Icon(
                            cat['icon'] as IconData, 
                            color: isSelected ? Colors.white : catColor, 
                            size: 28
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['label'] as String, 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                            color: isSelected ? catColor : Colors.black87
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {}, child: const Text('すべて見る')),
        ],
      ),
    );
  }

  // --- 店舗カード ---
  Widget _buildStoreCard(Map<String, dynamic> store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => CProductListPage(storeId: store['id'], storeName: store['store_name']),
          ));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              // 画像部分
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  image: store['store_image_url'] != null
                      ? DecorationImage(image: NetworkImage(store['store_image_url']), fit: BoxFit.cover)
                      : null,
                ),
                child: store['store_image_url'] == null 
                  ? Icon(Icons.store, size: 40, color: Colors.grey[400]) 
                  : null,
              ),
              // 情報部分
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store['store_name'] ?? '無名店舗', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(store['description'] ?? '', 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          const Text('4.5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(store['business_hours'] ?? '営業中', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 店舗がない時の表示 ---
  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('該当する店舗がありません', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}