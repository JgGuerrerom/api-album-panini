import 'package:flutter/material.dart';

class Paleta {
  static const Color fondo = Color(0xFF0F1A2E);
  static const Color superficie = Color(0xFF1B2A45);
  static const Color primario = Color(0xFF16C47F);
  static const Color dorado = Color(0xFFF2B544);
  static const Color textoPrincipal = Color(0xFFF5F7FA);
  static const Color textoSecundario = Color(0xFF9AAAC4);
}

ThemeData temaApp() {
  return ThemeData(
    scaffoldBackgroundColor: Paleta.fondo,
    primaryColor: Paleta.primario,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.dark(
      primary: Paleta.primario,
      surface: Paleta.superficie,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Paleta.fondo,
      foregroundColor: Paleta.textoPrincipal,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Paleta.primario,
        foregroundColor: Paleta.fondo,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

const double radioTarjeta = 16;