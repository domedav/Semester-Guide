import 'package:flutter/material.dart';
import 'home.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semester Guide',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color.fromRGBO(0xA8, 0x86, 0xDF, 1),
          secondary: Color.fromRGBO(0x25, 0x1C, 0x34, 1),
        ),
        useMaterial3: true,
      ),
      home: const AppHome(),
    );
  }
}