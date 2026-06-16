import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ── Fondos ──
  static const cloud = Color(0xFFFFF8F0);
  static const snowWhite = Color(0xFFFFFFFF);

  // ── Primarios pastel ──
  static const magicPink = Color(0xFFF8A9D8);
  static const softLilac = Color(0xFFC7A4FF);
  static const skyBlue = Color(0xFFA9DDFB);
  static const softMint = Color(0xFFBDF7D1);
  static const starGold = Color(0xFFFFE680);

  // ── Acentos saturados (botones, iconos activos) ──
  static const pinkAccent = Color(0xFFFF6FAE);
  static const lilacAccent = Color(0xFF9B6FE8);
  static const mintAccent = Color(0xFF4ECDC4);

  // ── Texto ──
  static const purpleText = Color(0xFF5C3A7D);
  static const purpleTextLight = Color(0xFF8B6BAF);

  // ── Feedback ──
  static const successGreen = Color(0xFF7ED957);
  static const hintOrange = Color(0xFFFFB84D);
  static const gentleError = Color(0xFFFF9BAA);

  // ── Gradientes predefinidos ──
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cloud, Color(0xFFF3E8FF)],
  );

  static const magicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [magicPink, softLilac],
  );

  static const skyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [skyBlue, softMint],
  );
}
