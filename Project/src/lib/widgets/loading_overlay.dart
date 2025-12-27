import 'package:flutter/material.dart';

/// ローディングオーバーレイウィジェット
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: indicatorColor ?? Theme.of(context).primaryColor,
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// フルスクリーンローディング
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const FullScreenLoading({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: indicatorColor ?? Theme.of(context).primaryColor,
            ),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// スケルトンローディング（プレースホルダー）
class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[200]!,
                Colors.grey[300]!,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// リストアイテム用スケルトン
class ListItemSkeleton extends StatelessWidget {
  final bool hasImage;
  final double imageSize;

  const ListItemSkeleton({
    super.key,
    this.hasImage = true,
    this.imageSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (hasImage) ...[
            SkeletonLoading(
              width: imageSize,
              height: imageSize,
              borderRadius: 8,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(
                  width: double.infinity,
                  height: 16,
                ),
                const SizedBox(height: 8),
                SkeletonLoading(
                  width: 150,
                  height: 12,
                ),
                const SizedBox(height: 8),
                SkeletonLoading(
                  width: 80,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
