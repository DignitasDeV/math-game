import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class ResponsiveActionGrid extends StatelessWidget {
  const ResponsiveActionGrid({
    required this.children,
    this.columns = 2,
    this.gap = AppSpacing.md,
    this.minRows = 0,
    super.key,
  });

  final List<Widget> children;
  final int columns;
  final double gap;
  final int minRows;

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(
        children.skip(i).take(columns).toList(growable: false),
      );
    }
    final rowCount = rows.length < minRows ? minRows : rows.length;

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
          if (rowIndex > 0) SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                for (var colIndex = 0; colIndex < columns; colIndex++) ...[
                  if (colIndex > 0) SizedBox(width: gap),
                  Expanded(
                    child: rowIndex < rows.length &&
                            colIndex < rows[rowIndex].length
                        ? rows[rowIndex][colIndex]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
