import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';
import 'c_product_list.dart';

/// 蠎苓・讀懃ｴ｢逕ｻ髱｢
class CStoreSearchPage extends StatefulWidget {
  const CStoreSearchPage({super.key});

  @override
  State<CStoreSearchPage> createState() => _CStoreSearchPageState();
}

class _CStoreSearchPageState extends State<CStoreSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '縺吶∋縺ｦ';
  String _sortBy = 'recommend';
  List<dynamic> _filteredStores = [];
  bool _isSearching = false;

  final List<String> _categories = [
    '縺吶∋縺ｦ',
    '譁咏炊',
    '繧ｫ繝輔ぉ',
    '繝輔ぃ繧ｹ繝医ヵ繝ｼ繝・,
    '繝ｩ繝ｼ繝｡繝ｳ',
    '鬟滓侭蜩・,
    '繧ｳ繝ｳ繝薙ル',
    '繧ｹ繧､繝ｼ繝・,
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'recommend', 'label': '縺翫☆縺吶ａ鬆・},
    {'value': 'distance', 'label': '霍晞屬縺瑚ｿ代＞鬆・},
    {'value': 'rating', 'label': '隧穂ｾ｡縺碁ｫ倥＞鬆・},
    {'value': 'delivery_time', 'label': '驟埼＃譎る俣縺檎洒縺・・},
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
        title: '蠎苓・繧呈爾縺・,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 讀懃ｴ｢繝舌・
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '蠎苓・蜷阪・譁咏炊蜷阪〒讀懃ｴ｢',
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
                // 繧ｫ繝・ざ繝ｪ繝輔ぅ繝ｫ繧ｿ繝ｼ
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
                            // TODO: 繧ｫ繝・ざ繝ｪ縺ｧ繝輔ぅ繝ｫ繧ｿ繝ｪ繝ｳ繧ｰ
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
          // 繧ｽ繝ｼ繝・
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stores.length}莉ｶ縺ｮ蠎苓・',
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
                      // TODO: 繧ｽ繝ｼ繝亥・逅・
                    }
                  },
                ),
              ],
            ),
          ),
          // 蠎苓・繝ｪ繧ｹ繝・
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
            _isSearching ? '讀懃ｴ｢邨先棡縺後≠繧翫∪縺帙ｓ' : '蠎苓・縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ',
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
            // 蠎苓・逕ｻ蜒・
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
                    store['store_name'] ?? '蠎苓・蜷阪↑縺・,
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
                      // 隧穂ｾ｡
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber[600]),
                          const SizedBox(width: 4),
                          const Text(
                            '4.5', // TODO: 螳滄圀縺ｮ隧穂ｾ｡
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' (120)', // TODO: 螳滄圀縺ｮ繝ｬ繝薙Η繝ｼ謨ｰ
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 驟埼＃譎る俣
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '20-30蛻・,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 驟埼＃譁・
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'ﾂ･300',
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
