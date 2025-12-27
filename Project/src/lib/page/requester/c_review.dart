import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../component/component.dart';
import '../../provider/provider.dart';
import '../../models/database_models.dart';
import '../../widgets/rating_widget.dart';

/// 注文完了後のレビュー画面
class CReviewPage extends StatefulWidget {
  final int orderId;
  final String storeName;
  final int storeId;

  const CReviewPage({
    super.key,
    required this.orderId,
    required this.storeName,
    required this.storeId,
  });

  @override
  State<CReviewPage> createState() => _CReviewPageState();
}

class _CReviewPageState extends State<CReviewPage> {
  double _storeRating = 0;
  double _deliveryRating = 0;
  final TextEditingController _storeCommentController = TextEditingController();
  final TextEditingController _deliveryCommentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _storeCommentController.dispose();
    _deliveryCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_storeRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('店舗の評価を入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: APIでレビューを送信
      await Future.delayed(const Duration(seconds: 1)); // モック

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レビューを投稿しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'レビューを投稿',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 店舗評価セクション
            _buildSectionTitle('店舗の評価'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingInputWidget(
                      initialRating: _storeRating,
                      size: 40,
                      onRatingChanged: (rating) {
                        setState(() => _storeRating = rating);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getRatingLabel(_storeRating),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _storeCommentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '料理の味や量、お店の対応などについてコメントを書いてください',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 配達評価セクション
            _buildSectionTitle('配達の評価'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '配達員',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RatingInputWidget(
                      initialRating: _deliveryRating,
                      size: 40,
                      onRatingChanged: (rating) {
                        setState(() => _deliveryRating = rating);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _getRatingLabel(_deliveryRating),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _deliveryCommentController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '配達の速さや対応についてコメントを書いてください（任意）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 送信ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'レビューを投稿',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('後で評価する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return '評価を選択してください';
    if (rating <= 1) return '非常に不満';
    if (rating <= 2) return '不満';
    if (rating <= 3) return '普通';
    if (rating <= 4) return '満足';
    return '非常に満足';
  }
}
