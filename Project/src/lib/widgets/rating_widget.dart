import 'package:flutter/material.dart';

/// 星評価ウィジェット
class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showLabel;
  final int? reviewCount;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.showLabel = false,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            return Icon(Icons.star, size: size, color: activeColor);
          } else if (rating > starValue - 1) {
            return Icon(Icons.star_half, size: size, color: activeColor);
          } else {
            return Icon(Icons.star_border, size: size, color: inactiveColor);
          }
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.6,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

/// 評価入力ウィジェット
class RatingInputWidget extends StatefulWidget {
  final double initialRating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onRatingChanged;
  final bool allowHalfRating;

  const RatingInputWidget({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 40,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
    this.allowHalfRating = true,
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_rating == starValue) {
                // 同じ星をタップしたら半分に
                if (widget.allowHalfRating) {
                  _rating = starValue - 0.5;
                }
              } else {
                _rating = starValue.toDouble();
              }
            });
            widget.onRatingChanged?.call(_rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              _rating >= starValue
                  ? Icons.star
                  : (_rating > starValue - 1 ? Icons.star_half : Icons.star_border),
              size: widget.size,
              color: _rating >= starValue - 0.5
                  ? widget.activeColor
                  : widget.inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

/// レビューカードウィジェット
class ReviewCard extends StatelessWidget {
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String date;
  final VoidCallback? onHelpful;
  final int? helpfulCount;

  const ReviewCard({
    super.key,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.onHelpful,
    this.helpfulCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    userAvatar != null ? NetworkImage(userAvatar!) : null,
                child: userAvatar == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RatingWidget(
                      rating: rating,
                      size: 14,
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(fontSize: 14),
          ),
          if (onHelpful != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onHelpful,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text(
                    helpfulCount != null && helpfulCount! > 0
                        ? '役に立った ($helpfulCount)'
                        : '役に立った',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
