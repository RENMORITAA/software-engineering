import 'package:flutter/material.dart';

/// 数量カウンターコンポーネント
/// カート画面などで商品の数量を変更する際に使用
class NumberCount extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const NumberCount({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 99,
    required this.onChanged,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > min;
    final canIncrease = value < max;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 減少ボタン
          _CountButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onPressed: () => onChanged(value - 1),
            iconSize: iconSize,
            activeColor: activeColor ?? Theme.of(context).primaryColor,
            inactiveColor: inactiveColor ?? Colors.grey[300]!,
          ),
          // 数量表示
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 増加ボタン
          _CountButton(
            icon: Icons.add,
            enabled: canIncrease,
            onPressed: () => onChanged(value + 1),
            iconSize: iconSize,
            activeColor: activeColor ?? Theme.of(context).primaryColor,
            inactiveColor: inactiveColor ?? Colors.grey[300]!,
          ),
        ],
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;

  const _CountButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.iconSize,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onPressed : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
