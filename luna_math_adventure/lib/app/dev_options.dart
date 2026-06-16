import 'package:flutter/foundation.dart';

class AppDevOptions {
  const AppDevOptions._();

  /// Development mode skips onboarding and unlocks every level.
  ///
  /// It is enabled by default for debug builds. Pass
  /// `--dart-define=LUNA_PROD_FLOW=true` to test the real onboarding and level
  /// locking flow locally.
  static const _forceDevMode = bool.fromEnvironment('LUNA_DEV_MODE');
  static const _forceProdFlow = bool.fromEnvironment('LUNA_PROD_FLOW');
  static const devMode = !_forceProdFlow && (kDebugMode || _forceDevMode);

  static const unlockAllLevels = devMode;
  static const skipOnboarding = devMode;

  /// Optional manual reset for testing first-run flows.
  static const resetOnFreshStart = bool.fromEnvironment(
    'LUNA_RESET_ON_START',
  );

  static const devProfileId = 'dev_profile';
}
