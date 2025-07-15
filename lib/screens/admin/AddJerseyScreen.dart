import 'package:flutter/material.dart';

class AddJerseyScreen extends StatefulWidget {
  const AddJerseyScreen({super.key});

  @override
  State<AddJerseyScreen> createState() => _AddJerseyScreenState();
}

class _AddJerseyScreenState extends State<AddJerseyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Add Jersey"),),);
  }
}