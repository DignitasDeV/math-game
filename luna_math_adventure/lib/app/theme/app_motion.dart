import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const quick = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 260);
  static const gentle = Duration(milliseconds: 320);

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeOutBack;
  static const exit = Curves.easeInCubic;

  static const dialog = AnimationStyle(
    duration: gentle,
    reverseDuration: quick,
    curve: standard,
    reverseCurve: exit,
  );

  static const bottomSheet = AnimationStyle(
    duration: gentle,
    reverseDuration: normal,
    curve: standard,
    reverseCurve: exit,
  );
}
