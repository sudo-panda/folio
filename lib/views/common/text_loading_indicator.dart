import 'package:flutter/material.dart';

class TextLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TextLoadingIndicator({
    required this.width,
    required this.height,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2)),
              child: LinearProgressIndicator(
          backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          minHeight: height,
          valueColor:
              AlwaysStoppedAnimation<Color>(foregroundColor ?? Theme.of(context).colorScheme.background),
        ),
      ),
    );
  }
}
