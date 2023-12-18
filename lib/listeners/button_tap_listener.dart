import 'package:flutter/material.dart';

class ButtonTapListener extends ChangeNotifier {
  bool isClicked = false;

  void clickEvent() {
    isClicked = !isClicked;
    notifyListeners();
  }
}
