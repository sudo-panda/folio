import 'package:flutter/material.dart';

class TextLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;

  const TextLoadingIndicator({
    @required this.width,
    @required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(2)),
              child: LinearProgressIndicator(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          minHeight: height,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).backgroundColor),
        ),
      ),
    );
  }
}
