import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jersey_ecommerce/firebase_options.dart';
import 'package:jersey_ecommerce/screens/NavigationScreen.dart';

void main() async{
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
 );
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


