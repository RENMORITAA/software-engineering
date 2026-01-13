import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/image_upload_service.dart';

/// 画像選択・プレビュー用ウィジェット
class ImagePickerWidget extends StatefulWidget {
  final String? currentImageUrl;
  final Function(Uint8List bytes, String filename) onImageSelected;
  final double size;
  final bool isCircle;
  final String placeholder;

  const ImagePickerWidget({
    super.key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.isCircle = true,
    this.placeholder = 'タップして画像を選択',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web用: HTML input elementを使用
      await _pickImageWeb();
    } else {
      // モバイル用のimage_pickerはここに実装
      // 今回はWebに集中
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('モバイルでの画像選択は未実装です')),
      );
    }
  }

  Future<void> _pickImageWeb() async {
    // ignore: avoid_web_libraries_in_flutter
    // Web用にdart:htmlを使わずに、シンプルな実装
    // 実際の実装ではfile_pickerパッケージを使用推奨
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('画像選択機能を使用するには file_picker パッケージを追加してください'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUrl = _selectedImageBytes != null
        ? null
        : ImageUploadService.getFullImageUrl(widget.currentImageUrl);

    Widget imageWidget;

    if (_isLoading) {
      imageWidget = const Center(child: CircularProgressIndicator());
    } else if (_selectedImageBytes != null) {
      imageWidget = Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (displayUrl != null && displayUrl.isNotEmpty) {
      imageWidget = Image.network(
        displayUrl,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(color: Colors.grey[300]!, width: 2),
          color: Colors.grey[100],
        ),
        clipBehavior: Clip.antiAlias,
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: widget.size * 0.3,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          widget.placeholder,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// ネットワーク画像表示ウィジェット（キャッシュ対応）
class NetworkImageWithPlaceholder extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fullUrl = ImageUploadService.getFullImageUrl(imageUrl);

    if (fullUrl.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    return Image.network(
      fullUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _defaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultError();
      },
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: 40,
      ),
    );
  }
}
