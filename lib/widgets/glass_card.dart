import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(vertical: 10),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            // Đã sửa lỗi: Thay thế withOpacity
            color: Colors.white.withAlpha(64), // 0.25 opacity
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border:
                // Đã sửa lỗi: Thay thế withOpacity
                Border.all(
                    color: Colors.white.withAlpha(77),
                    width: 1.5), // 0.3 opacity
          ),
          child: child,
        ),
      ),
    );
  }
}
