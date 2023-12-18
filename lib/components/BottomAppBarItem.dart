import 'package:flutter/material.dart';

class BottomAppBarItem extends StatefulWidget {
  final MaterialButton materialButton;
  bool hasNotification = false;
  BottomAppBarItem(
      {super.key, required this.materialButton, required this.hasNotification});

  @override
  State<BottomAppBarItem> createState() => _BottomAppBarItemState();
}

class _BottomAppBarItemState extends State<BottomAppBarItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
