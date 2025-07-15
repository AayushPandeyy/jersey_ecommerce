import 'package:flutter/material.dart';

class ViewOrdersScreen extends StatefulWidget {
  const ViewOrdersScreen({super.key});

  @override
  State<ViewOrdersScreen> createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("View Orders"),),);
  }
}