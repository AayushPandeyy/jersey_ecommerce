import 'package:flutter/material.dart';

class ViewJerseyScreen extends StatefulWidget {
  const ViewJerseyScreen({super.key});

  @override
  State<ViewJerseyScreen> createState() => _ViewJerseyScreenState();
}

class _ViewJerseyScreenState extends State<ViewJerseyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("View Jersey"),),);
  }
}