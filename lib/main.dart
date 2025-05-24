import 'package:flutter/material.dart';
import 'package:jersey_ecommerce/HomePage.dart';
import 'package:jersey_ecommerce/NavigationScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: NavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


