import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

// https://blog.logrocket.com/how-to-create-a-grid-list-in-flutter-using-gridview/
// https://stackoverflow.com/questions/55440184/flutter-gesturedetector-how-to-pinch-in-out-or-zoom-in-out-text-using-two-finge
// https://api.flutter.dev/flutter/widgets/GridView-class.html
class LookBookScreen extends StatefulWidget {
  final User? user;
  const LookBookScreen({super.key, this.user});

  @override
  State<LookBookScreen> createState() => _LookBookScreenState();
}

class _LookBookScreenState extends State<LookBookScreen> {
  int _crossAxisCount = 4;
  final int _baseCrossAxisCount = 4;
  double _baseCrossAxisScale = 1;
  double _crossAxisScale = 1;
  double _baseFontScale = 1;
  double _fontScale = 1;
  double _fontSize = 20;
  final double _baseFontSize = 20;
  int fingersTouching = 0;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          // backgroundColor: Colors.black,
          elevation: 0.0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month),
              enableFeedback: true,
              tooltip: 'Look Book Calendar',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                FontAwesomeIcons.pencilRuler,
                size: 20.0,
              ),
              enableFeedback: true,
              tooltip: 'Size Tracker',
            )
          ],
        ),
        body: Listener(
          onPointerDown: ((event) {
            fingersTouching += 1;
            print('$event $fingersTouching');
          }),
          onPointerUp: ((PointerUpEvent event) {
            fingersTouching -= 1;
            print('$event $fingersTouching');
          }),
          child: GestureDetector(
            onScaleStart: (scaleStartDetails) {
              if (fingersTouching >= 2) {
                _baseFontScale = _fontScale;
                _baseCrossAxisScale = _crossAxisScale;
              }
            },
            onScaleUpdate: (scaleUpdateDetails) {
              if (fingersTouching >= 2) {
                setState(
                  () {
                    _fontScale = (_baseFontScale * scaleUpdateDetails.scale)
                        .clamp(.5, 5);
                    _fontSize = _fontScale * _baseFontSize;
                    _crossAxisScale =
                        (_baseCrossAxisScale * scaleUpdateDetails.scale)
                            .clamp(.5, 5);
                    _crossAxisCount =
                        (_baseCrossAxisCount / _crossAxisScale).floor();
                    if (_crossAxisCount < 1) {
                      _crossAxisCount = 1;
                    }
                  },
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 35),
              child: GridView.count(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                children: List.generate(
                  100,
                  (index) {
                    return Container(
                      color: Colors.grey,
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Item $index',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: _fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
