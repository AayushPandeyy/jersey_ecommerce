import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  const SizeSelector({super.key});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizeTile("XS"),
          SizeTile("S"),
          SizeTile("M"),
          SizeTile("L"),
          SizeTile("XL"),
          SizeTile("XXL"),
        ],
      ),
    );
  }
}

Widget SizeTile(String title) {
  return Container(
    width: 60,
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color.fromARGB(255, 224, 224, 224),
        width: 1,
      ),
    ),
    child: Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
