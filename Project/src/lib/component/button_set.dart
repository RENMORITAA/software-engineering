import 'package:flutter/material.dart';

/// ボタンセットコンポーネント
/// キャンセル・確定などのボタンペアを表示
class ButtonSet extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final Color? primaryColor;
  final Color? secondaryColor;
  final bool isLoading;
  final bool primaryEnabled;
  final bool secondaryEnabled;
  final IconData? primaryIcon;
  final IconData? secondaryIcon;

  const ButtonSet({
    super.key,
    this.primaryText = '確定',
    this.secondaryText = 'キャンセル',
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.primaryColor,
    this.secondaryColor,
    this.isLoading = false,
    this.primaryEnabled = true,
    this.secondaryEnabled = true,
    this.primaryIcon,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: secondaryEnabled && !isLoading
                  ? onSecondaryPressed
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: secondaryColor ?? Colors.grey[700],
                side: BorderSide(
                  color: secondaryColor ?? Colors.grey[400]!,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: secondaryIcon != null
                  ? Icon(secondaryIcon, size: 20)
                  : const SizedBox.shrink(),
              label: Text(
                secondaryText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: primaryEnabled && !isLoading
                  ? onPrimaryPressed
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor ?? Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : (primaryIcon != null
                      ? Icon(primaryIcon, size: 20)
                      : const SizedBox.shrink()),
              label: Text(
                primaryText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 単一ボタンコンポーネント
class SingleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final bool isOutlined;

  const SingleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: enabled && !isLoading ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? Theme.of(context).primaryColor,
            side: BorderSide(
              color: color ?? Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color ?? Theme.of(context).primaryColor,
                  ),
                )
              : (icon != null
                  ? Icon(icon, size: 20)
                  : const SizedBox.shrink()),
          label: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (icon != null
                ? Icon(icon, size: 20)
                : const SizedBox.shrink()),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
