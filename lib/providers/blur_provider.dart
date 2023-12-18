import 'package:flutter/material.dart';

class Blur with ChangeNotifier {
  bool _blur = false;

  bool get blur => _blur;

  void setBlur(bool blur) {
    _blur = blur;
    notifyListeners();
  }
}
