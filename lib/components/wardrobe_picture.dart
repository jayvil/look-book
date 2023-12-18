//https://www.tldevtech.com/snippet/flutter-glassmorphism-card/
// https://stackoverflow.com/questions/70015558/flutter-card-with-gridview
// https://www.woolha.com/tutorials/flutter-display-image-from-file-examples
import 'dart:io';

import 'package:flutter/material.dart';

class WardrobePicture extends StatefulWidget {
  final String imagePath;
  const WardrobePicture({super.key, required this.imagePath});
  @override
  State<WardrobePicture> createState() => _WardrobePictureState();
}

class _WardrobePictureState extends State<WardrobePicture> {
  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(widget.imagePath),
    );
  }
}
