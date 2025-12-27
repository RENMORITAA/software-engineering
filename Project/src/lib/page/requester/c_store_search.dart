import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';
import 'c_product_list.dart';

/// 店舗検索画面
class CStoreSearchPage extends StatefulWidget {
  const CStoreSearchPage({super.key});

  @override
  State<CStoreSearchPage> createState() => _CStoreSearchPageState();
}

class _CStoreSearchPageState extends State<CStoreSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'すべて';
  String _sortBy = 'recommend';
  List<dynamic> _filteredStores = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'すべて',
    '料理',
    'カフェ',
    'ファストフード',
    'ラーメン',
    '食料品',
    'コンビニ',
    'スイーツ',
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'recommend', 'label': 'おすすめ順'},
    {'value': 'distance', 'label': '距離が近い順'},
    {'value': 'rating', 'label': '評価が高い順'},
    {'value': 'delivery_time', 'label': '配達時間が短い順'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final storeProvider = context.read<StoreProvider>();
    final stores = storeProvider.stores;

    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredStores = stores;
      } else {
        _filteredStores = stores.where((store) {
          final storeName = (store['store_name'] ?? '').toString().toLowerCase();
          final description = (store['description'] ?? '').toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return storeName.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final stores = _isSearching ? _filteredStores : storeProvider.stores;

    return Scaffold(
      appBar: const TitleAppBar(
        title: '店舗を探す',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 検索バー
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '店舗名・料理名で検索',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _performSearch,
                ),
                const SizedBox(height: 12),
                // カテゴリフィルター
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            // TODO: カテゴリでフィルタリング
                          },
                          selectedColor:
                              Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // ソート
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stores.length}件の店舗',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort),
                  items: _sortOptions.map((option) {
                    return DropdownMenuItem(
                      value: option['value'],
                      child: Text(
                        option['label']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                      // TODO: ソート処理
                    }
                  },
                ),
              ],
            ),
          ),
          // 店舗リスト
          Expanded(
            child: storeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : stores.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index] as Map<String, dynamic>;
                          return _buildStoreCard(store);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching ? '検索結果がありません' : '店舗が見つかりません',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CProductListPage(
              storeId: store['id'],
              storeName: store['store_name'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 店舗画像
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: store['store_image_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(store['store_image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: store['store_image_url'] == null
                  ? Center(
                      child: Icon(
                        Icons.store,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['store_name'] ?? '店舗名なし',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // 評価
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          const Text(
                            '4.5', // TODO: 実際の評価
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' (120)', // TODO: 実際のレビュー数
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 配達時間
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '20-30分',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 配達料
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '¥300',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
