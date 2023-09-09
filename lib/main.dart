import 'package:flutter/material.dart';
import 'package:mi_app_rara/pages/cosas.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    title: 'My Aplicación',
    theme: ThemeData(useMaterial3: true,
    colorSchemeSeed: const Color.fromARGB(255, 255, 255, 255) 
    ),home: const Cosas(),
    

    );
  }
}
