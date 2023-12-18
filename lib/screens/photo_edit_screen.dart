// import 'dart:io';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;

import '../components/image_editor.dart';
import '../components/tool_box.dart';
import '../providers/edit_tool_provider.dart';

// TODO: https://stackoverflow.com/questions/50989513/how-do-i-crop-images-in-flutter

class PhotoEditScreen extends StatefulWidget {
  // Instance fields
  final XFile? image;

  const PhotoEditScreen(this.image, {super.key});

  @override
  State<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  late final ui.Image uiImage;
  late final Uint8List bytes;
  late final img.Image imgImage;
  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  late final ui.Canvas canvas;
  late final ImageEditor paintController;
  // late final CheckerboardPainter checkerboardPainter;
  List<DrawingPoint> drawingPoints = [];
  Color selectedColor = Colors.black;
  List<Color> colors = [
    Colors.transparent,
    Colors.black,
    Colors.white70,
    Colors.red,
    Colors.pink,
    Colors.amberAccent,
    Colors.green,
    Colors.purple,
  ];
  double strokeWidth = 50;
  Tools tool = Tools.eraser;

  List<Map<Widget, Widget>> editTools = [
    {
      const DrawTool(): ElevatedButton(
        onPressed: () {},
        child: const Icon(Icons.save),
      ),
      // EraserTool(
      //   xfile: widget.image!.path,
      // ): ElevatedButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.scale),
      // ),
    }
  ];

  Future<img.Image> _loadImage(XFile file) async {
    final data = await file.readAsBytes();
    uiImage = await decodeImageFromList(data);
    // checkerboardPainter = CheckerboardPainter(uiImage);
    // paintController = ImageEditor(uiImage, drawingPoints);
    Uint8List bytes = await File(widget.image!.path).readAsBytes();
    imgImage = img.decodeImage(bytes)!;
    // checkerboardPainter = CheckerboardPainter(uiImage);
    return imgImage;
  }

  Widget _buildColorChooser(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          print('set color');
          selectedColor = color;
        });
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    // _loadImage(widget.image!);
    canvas = Canvas(pictureRecorder);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Edit'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.undoAlt),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.redoAlt),
          ),
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                child: Text('Clear all edits'),
              )
            ];
          }),
        ],
      ),
      body: FutureBuilder(
        future: _loadImage(widget.image!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/checkerboard-light.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: FittedBox(
                    child: SizedBox(
                      width: uiImage.width.toDouble(),
                      height: uiImage.height.toDouble(),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageEditor(uiImage: uiImage),
                        ],
                      ),
                    ),
                  ),
                ),
                // Expanded(child: Container()),
                const Expanded(child: ToolBox()),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .05,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Save'),
                              // const Icon(Icons.save),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

/*
*
* DRAW TOOL
* */
class DrawTool extends StatefulWidget {
  const DrawTool({super.key});

  @override
  State<DrawTool> createState() => _DrawToolState();
}

class _DrawToolState extends State<DrawTool> {
  List<Widget> colorWidgets = [];
  Color selectedColor = Colors.black;
  List<Color> colors = [
    Colors.transparent,
    Colors.black,
    // Colors.white,
    Colors.red,
    Colors.pink,
    Colors.amberAccent,
    Colors.green,
    Colors.purple,
  ];

  Widget _buildColorChooser(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          // print('set color');
          selectedColor = color;
        });
      },
      child: Container(
        height: isSelected ? 47 : 40,
        width: isSelected ? 47 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    colorWidgets = List.generate(
      colors.length,
      (index) => _buildColorChooser(colors[index]),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // The Tool Icons
        children: List.generate(
          colors.length,
          (index) => _buildColorChooser(colors[index]),
        ),
      ),
    );
  }
}

/*
*
* CROP TOOL
* */

class DrawingPoint {
  Offset offset;
  Paint paint;
  DrawingPoint(this.offset, this.paint);
}

// class CheckerboardPainter extends CustomPainter {
//   // TODO https://stackoverflow.com/questions/44179889/how-do-i-set-background-image-in-flutter
//   // TODO set background image of editor screen to checkered background
//   final ui.Image image;
//   CheckerboardPainter(this.image);
//   @override
//   void paint(Canvas canvas, Size size) {
//     // print("canvas width ${size.width}");
//     // print("canvas height ${size.height}");
//     final squareSize = size.width / 30;
//     final paint1 = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 100
//       ..strokeCap = StrokeCap.round;
//     final paint2 = Paint()
//       ..color = Colors.grey.shade300
//       ..strokeWidth = 100
//       ..strokeCap = StrokeCap.round;
//     print(image.height);
//     print(image.width);
//     // for (int i = 0; i < 30; i++) {
//     //   for (int j = 0; j < size.height; j++) {
//     //     double x = i * squareSize;
//     //     double y = j * squareSize;
//     //     if ((i + j) % 2 == 0) {
//     //       canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint1);
//     //     } else {
//     //       canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint2);
//     //     }
//     //   }
//     // }
//     // canvas.save();
//     // canvas.restore();
//     // Offset startingPoint = Offset(0, size.height / 2);
//     // Offset endingPoint = Offset(size.width, size.height / 2);
//
//     // canvas.drawLine(startingPoint, endingPoint, paint);
//   }
//
//   @override
//   bool shouldRepaint(CheckerboardPainter oldDelegate) {
//     return oldDelegate.image == image;
//     ;
//   }
// }

// class _DrawingPainter extends CustomPainter {
//   final ui.Image image;
//   final _paint = Paint()..blendMode = BlendMode.clear;
//   final _points = <Offset>[];
//   final List<DrawingPoint?> drawingPoints;
//   _DrawingPainter(this.image, this.drawingPoints);
//
//   void updatePoints(Offset globalPosition) {
//     _points.add(globalPosition);
//     // notifyListeners();
//   }
//
//   void finish() {
//     _points.clear();
//     // notifyListeners();
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     // https://stackoverflow.com/questions/59626727/how-to-erase-clip-from-canvas-custompaint
//     // canvas.saveLayer(Rect.largest, Paint());
//     final paint = Paint()
//       ..color = Colors.red
//       ..strokeWidth = 100
//       ..strokeCap = StrokeCap.round;
//
//     final _paint = Paint()
//       ..blendMode = BlendMode.clear
//       ..strokeWidth = 400;
//     // canvas.save();
//     // canvas.saveLayer(Rect.largest, Paint());
//     canvas.drawImage(image, Offset.zero, paint);
//   }
//
//   @override
//   bool shouldRepaint(_DrawingPainter oldDelegate) {
//     // return image != oldDelegate.image;
//     return false;
//   }
// }
