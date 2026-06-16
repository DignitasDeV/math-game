import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({
    required this.child,
    this.maxWidth = AppBreakpoints.contentMaxWidth,
    this.padding = AppSpacing.screenPadding,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding,
              child: SizedBox(
                height: constraints.maxHeight,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
