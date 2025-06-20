import 'package:flutter/material.dart';
import 'screens/main_home_screen.dart';

void main() {
  runApp(const QuranApp());
}
class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran Audio Matcher',
      theme: ThemeData.dark(),
      home: const MainHomeScreen(),
    );
  }
}