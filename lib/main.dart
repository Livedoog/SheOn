import 'package:flutter/material.dart';
import 'package:sheon/homepage.dart';

void main() async {
  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheon',
      debugShowCheckedModeBanner: false,
      home:HomePage(isLeftHandMode:false));
  }
}

