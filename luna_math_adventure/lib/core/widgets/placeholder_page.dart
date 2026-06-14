import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_typography.dart';
import 'magic_scaffold.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.message,
    this.primaryLabel,
    this.primaryRoute,
    super.key,
  });

  final String title;
  final String message;
  final String? primaryLabel;
  final String? primaryRoute;

  @override
  Widget build(BuildContext context) {
    return MagicScaffold(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.title),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.body),
          const Spacer(),
          if (primaryLabel != null && primaryRoute != null)
            FilledButton(
              onPressed: () => context.go(primaryRoute!),
              child: Text(primaryLabel!),
            ),
        ],
      ),
    );
  }
}
