import 'package:flutter/material.dart';
import 'package:mwakili/auth/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mwakili',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        fontFamily: 'MyCustomFont',
      ),
      
      home: const SplashView(),
    );
  }
}