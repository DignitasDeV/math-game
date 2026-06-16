import 'package:flutter/material.dart';

import 'safe_asset_image.dart';

class ResponsiveAssetBackground extends StatelessWidget {
  const ResponsiveAssetBackground({
    required this.assetPath,
    this.placeholder = const SizedBox.shrink(),
    super.key,
  });

  final String assetPath;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeAssetImage(
        assetPath: assetPath,
        fit: BoxFit.cover,
        placeholder: placeholder,
      ),
    );
  }
}
