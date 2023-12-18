import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageEditor extends StatefulWidget {
  final ui.Image uiImage;
  const ImageEditor({super.key, required this.uiImage});

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  late final _DrawingPainter paintController;
  List<DrawingPoint> drawingPoints = [];
  Color selectedColor = Colors.red;
  double strokeWidth = 90;
  @override
  void initState() {
    paintController = _DrawingPainter(widget.uiImage, drawingPoints);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          drawingPoints.add(
            DrawingPoint(
              details.localPosition,
              Paint()
                ..color = selectedColor
                ..isAntiAlias = true
                ..strokeWidth = strokeWidth
                ..strokeCap = StrokeCap.round
                ..blendMode = BlendMode.clear,
            ),
          );
        });
      },
      onPanUpdate: (details) {
        setState(
          () {
            drawingPoints.add(
              DrawingPoint(
                details.localPosition,
                Paint()
                  ..color = selectedColor
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth
                  ..strokeCap = StrokeCap.round
                  ..blendMode = BlendMode.clear,
              ),
            );
          },
        );
      },
      onPanEnd: (details) {
        setState(() {
          Paint paint = Paint()..color = Colors.transparent;
          drawingPoints.add(DrawingPoint(drawingPoints.last.offset, paint));
        });
      },
      child: CustomPaint(
        painter: _DrawingPainter(widget.uiImage, drawingPoints),
      ),
    );
  }
}

/*
*
* IMAGE EDITOR
* https://github.com/samirpokharel/Drawing_board_app/blob/main/lib/main.dart
* https://www.youtube.com/watch?v=HI-PL37MdRM
* */
class _DrawingPainter extends CustomPainter {
  final ui.Image image;
  final _paint = Paint()..blendMode = BlendMode.clear;
  final _points = <Offset>[];
  final List<DrawingPoint?> drawingPoints;
  _DrawingPainter(this.image, this.drawingPoints);

  void updatePoints(Offset globalPosition) {
    _points.add(globalPosition);
    // notifyListeners();
  }

  void finish() {
    _points.clear();
    // notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    // https://stackoverflow.com/questions/59626727/how-to-erase-clip-from-canvas-custompaint
    // canvas.saveLayer(Rect.largest, Paint());
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 100
      ..strokeCap = StrokeCap.round;

    final paint0 = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 400;
    // canvas.save();
    // canvas.saveLayer(Rect.largest, Paint());
    canvas.drawImage(image, Offset.zero, paint);

    // final _paint = Paint();
    // final opacity = 0.0;
    // paint.color = Color.fromRGBO(0, 0, 0, opacity);
    // Rect myRect1 = const Offset(1.0, 2.0) & const Size(3.0, 4.0);
    // Rect myRect2 = const Offset(1.0, 2.0) & const Size(3.0, 4.0);
    // canvas.drawCircle(Offset(0, 0), 10, paint);

    // Offset startingPoint = Offset(0, size.height / 2);
    // Offset endingPoint = Offset(size.width, size.height / 2);
    //
    // for (final offset in _points) {
    //   canvas.drawCircle(offset, 20.0, _paint);
    // }
    //
    // canvas.drawLine(startingPoint, endingPoint, _paint);
    // canvas.restore();

    for (int i = 0; i < drawingPoints.length - 1; i++) {
      DrawingPoint? current = drawingPoints[i];
      DrawingPoint? next = drawingPoints[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current.offset, next.offset, current.paint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) {
    // return image != oldDelegate.image;
    return true;
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint(this.offset, this.paint);
}
