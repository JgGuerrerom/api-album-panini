import 'package:flutter/material.dart';
import 'tema.dart';
import 'pantallas/login.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Album Panini 2026',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: const PantallaLogin(),
    );
  }
}