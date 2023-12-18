import 'package:flutter/material.dart';

class ClothingItemScreen extends StatefulWidget {
  const ClothingItemScreen({super.key, required this.title});
  final String title;
  @override
  State<ClothingItemScreen> createState() => _ClothingItemScreenState();
}

class _ClothingItemScreenState extends State<ClothingItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}
