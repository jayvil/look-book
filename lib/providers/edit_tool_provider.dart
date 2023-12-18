import 'package:flutter/material.dart';

// https://www.waldo.com/blog/flutter-enum

enum Tools { hand, eraser, snip, crop, auto }

extension ToolsExtension on Tools {
  Widget get toolSettings {
    switch (this) {
      case Tools.hand:
        return Container(
          child: const Text('Hand Tool'),
        );
      case Tools.eraser:
        return Container(
          child: const Text('Eraser Tool'),
        );
      case Tools.snip:
        return Container(
          child: const Text('Snip Tool'),
        );
      case Tools.crop:
        return Container(
          child: const Text('Crop Tool'),
        );
      case Tools.auto:
        return Container(
          child: const Text('Auto Tool'),
        );
      default:
        return Container();
    }
  }
}

class EditTool with ChangeNotifier {
  Tools _tool = Tools.crop;

  Tools get tool => _tool;

  void setTool(Tools tool) {
    _tool = tool;
    notifyListeners();
  }
}
