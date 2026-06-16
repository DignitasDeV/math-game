import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Loads the asset manifest once and caches it for the lifetime of the app.
Future<Set<String>> _manifestAssets = _loadManifest();

Future<Set<String>> _loadManifest() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  } catch (_) {
    return const <String>{};
  }
}

/// An [Image.asset] wrapper that checks the [AssetManifest] before attempting
/// to load. If the asset key is not present, [placeholder] is shown instead of
/// triggering a network 404 on Flutter Web.
class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage({
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.placeholder = const SizedBox.shrink(),
    super.key,
  });

  final String assetPath;
  final BoxFit fit;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<Set<String>>(
          future: _manifestAssets,
          builder: (context, snapshot) {
            final assets = snapshot.data;
            if (assets == null) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: placeholder,
              );
            }
            if (!assets.contains(assetPath)) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: placeholder,
              );
            }
            return Image.asset(
              assetPath,
              fit: fit,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              errorBuilder: (_, __, ___) => placeholder,
            );
          },
        );
      },
    );
  }
}
