import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_lookbook/providers/blur_provider.dart';
import 'package:my_lookbook/screens/account_screen.dart';
import 'package:my_lookbook/screens/explore_screen.dart';
import 'package:my_lookbook/screens/lookbook_screen.dart';
import 'package:my_lookbook/screens/wardrobe_screenNew.dart';
import 'package:provider/provider.dart';

import '../components/modals/camera_staging_modal.dart';
import '../theme/theme_manager.dart';

/*
* COLOR PALATTE 1: https://colorhunt.co/palette/222831393e4600adb5eeeeee
* dark mode
* 222831
* 393E46
* 00ADB5
* EEEEEE
*
* Light mode https://colorhunt.co/palette/c2ded1ece5c7cdc2ae354259
* C2DED1
* ECE5C7
* CDC2AE
* 354259
*
* default color palatte: https://colorhunt.co/palette/f0e5cff7f6f2c8c6c64b6587
* F0E5CF
* F7F6F2
* C8C6C6
* 4B6587
* */

// TODO slide up page for bottom nav to hold other nav items
// TODO slide left and right to change nav pages
// https://api.flutter.dev/flutter/widgets/PageView-class.html
//https://stackoverflow.com/questions/56042354/flutter-expand-bottomnavigationbar-by-swiping-or-pressing-the-floatingactionbu
//https://stackoverflow.com/questions/52124133/blur-behind-drawer-in-flutter
// https://www.youtube.com/watch?v=L_QMsE2v6dw
/*
* // FutureBuilder<DatabaseEvent>(
            //   future: FirebaseDatabase.instance
            //       .ref('users')
            //       .child(widget.uid!)
            //       .once(),
            //   builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            //     if (snapshot.hasData) {
            //       Map<dynamic, dynamic> map =
            //           snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            //       return Text('Welcome ${map['name']}');
            //     } else {
            //       return CircularProgressIndicator();
            //     }
            //   },
            // ),
* */

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, this.user, this.activeIndex});
  final User? user;
  final int? activeIndex;
  // final ThemeManager themeManager;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int activeIndex = 0;
  final String title = 'Home Page';
  static const double _minHeight = 70;
  static const double _maxHeight = 150;
  Offset _offset = const Offset(0, _minHeight);
  bool _isOpen = false;
  List<Map<Widget, String>> pages = [];
  final PageStorageBucket bucket = PageStorageBucket();
  // Widget currentScreen = HomeScreen(uid: widget.uid);
  final PageController _pageController = PageController();
  final ImagePicker picker = ImagePicker();
  bool longPress = false;

  void changeActivePage(int index) {
    setState(() {
      activeIndex = index;
      // Jump to page when clicking in the bottom nav
      // _pageController.jumpToPage(index);
    });
  }

  @override
  void initState() {
    pages = [
      // {HomeScreen(uid: widget.uid): 'Home'},
      {ExploreScreen(user: widget.user): 'Explore'},
      {const WardrobeScreen(): 'My Wardrobe'},
      {LookBookScreen(user: widget.user): 'My Look Books'},
      {AccountScreen(user: widget.user): 'My Account'}
    ];
    super.initState();
    changeActivePage(widget.activeIndex!);
  }

  // first it opens the sheet and when called again it closes.
  void _handleClick() {
    _isOpen = !_isOpen;
    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (_isOpen) {
        double value = _offset.dy +
            11; // we increment the height of the Container by 10 every 5ms
        _offset = Offset(0, value);
        if (_offset.dy > _maxHeight) {
          _offset =
              const Offset(0, _maxHeight); // makes sure it does't go above maxHeight
          timer.cancel();
        }
      } else {
        double value = _offset.dy - 10; // we decrement the height by 10 here
        _offset = Offset(0, value);
        if (_offset.dy < _minHeight) {
          _offset = const Offset(
              0, _minHeight); // makes sure it doesn't go beyond minHeight
          timer.cancel();
        }
      }
      setState(() {});
    });
  }

  Widget? _getFab() {
    print(activeIndex);
    if (activeIndex == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: SpeedDial(
          useRotationAnimation: true,
          mini: false,
          spacing: 10.0,
          // animationAngle: 0.0,
          tooltip: 'Add to your wardrobe',
          heroTag: 'hero tag',
          animationCurve: Curves.elasticInOut,
          // animatedIconTheme: IconThemeData(size: 22.0),
          animationDuration: const Duration(milliseconds: 120),
          curve: Curves.easeIn,
          direction: SpeedDialDirection.up,
          renderOverlay: true,
          icon: Icons.add,
          // icon: Transform.rotate(
          //   child: Icons.close,
          //   angle: -math.pi / 4,
          // ), //icon on Floating action button
          activeIcon: Icons.close, //icon when menu is expanded on button
          backgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.blue
              : Colors.blue, //background color of button
          foregroundColor: Colors.white, //font color, icon color in button
          activeBackgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.red[400]
              : Colors.red[400], //background color when menu is expanded
          activeForegroundColor: Colors.white,
          buttonSize: const Size(56.0, 56.0), //button size
          visible: true,
          closeManually: false,
          overlayColor: null,
          overlayOpacity: 0.0,
          onOpen: () => print('OPENING DIAL'), // action when menu opens
          onClose: () => print('DIAL CLOSED'), //action when menu closes
          elevation: 10.0, //shadow elevation of button
          shape: const CircleBorder(), //shape of button
          children: [
            SpeedDialChild(
              //speed dial child
              child: const Icon(Icons.post_add_rounded),
              backgroundColor: Provider.of<ThemeManager>(context).isDark
                  ? Colors.grey[700]
                  : Colors.grey[50],
              foregroundColor: Colors.black,
              label: 'Create new post',
              labelStyle: const TextStyle(
                fontSize: 15.0,
              ),
              onTap: () {
                print('selection');
              },
              onLongPress: () => print('FIRST CHILD LONG PRESS'),
            ),
          ],
        ),
      );
    } else if (activeIndex == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              longPress = true;
            });
          },
          child: SpeedDial(
            useRotationAnimation: true,
            mini: false,
            spacing: 10.0,
            // animationAngle: 0.0,
            // tooltip: 'Add clothes to your wardrobe',
            // heroTag: 'hero tag',
            animationCurve: Curves.elasticInOut,
            // animatedIconTheme: IconThemeData(size: 22.0),
            animationDuration: const Duration(milliseconds: 120),
            curve: Curves.easeIn,
            direction: SpeedDialDirection.up,
            renderOverlay: true,
            icon: Icons.add,
            // icon: Transform.rotate(
            //   child: Icons.close,
            //   angle: -math.pi / 4,
            // ), //icon on Floating action button
            activeIcon: Icons.close, //icon when menu is expanded on button
            backgroundColor: Provider.of<ThemeManager>(context).isDark
                ? Colors.blue
                : Colors.blue, //background color of button
            foregroundColor: Colors.white, //font color, icon color in button
            activeBackgroundColor: Provider.of<ThemeManager>(context).isDark
                ? Colors.red[400]
                : Colors.red[400], //background color when menu is expanded
            activeForegroundColor: Colors.white,
            buttonSize: const Size(56.0, 56.0), //button size
            visible: true,
            closeManually: false,
            overlayColor: null,
            overlayOpacity: 0.0,
            onPress: () {
              HapticFeedback.lightImpact();
              sleep(const Duration(milliseconds: 10));
              showBarModalBottomSheet(
                overlayStyle: SystemUiOverlayStyle.light,
                context: context,
                builder: (context) => const CameraStagingModal(),
                isDismissible: true,
                enableDrag: true,
              );
            },
            onOpen: () {
              HapticFeedback.heavyImpact();
              context.read<Blur>().setBlur(true);
            }, // action when menu opens
            onClose: () {
              context.read<Blur>().setBlur(false);
              setState(() {
                longPress = false;
              });
            }, //action when menu closes
            elevation: 10.0, //shadow elevation of button
            shape: const CircleBorder(), //shape of button
            children: longPress
                ? []
                : [
                    SpeedDialChild(
                      //speed dial child
                      child: const Icon(Icons.add_a_photo_rounded),
                      backgroundColor: Provider.of<ThemeManager>(context).isDark
                          ? Colors.grey[700]
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      label: 'Camera',
                      labelStyle: const TextStyle(
                        fontSize: 15.0,
                      ),
                      onTap: () async {
                        // Capture a photo
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);
                        // await Navigator.of(context).push(
                        //   CupertinoPageRoute(
                        //     builder: (context) => CameraScreen(user: widget.user),
                        //   ),
                        // );
                      },
                      onLongPress: () => print('FIRST CHILD LONG PRESS'),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.add_photo_alternate_rounded),
                      backgroundColor: Provider.of<ThemeManager>(context).isDark
                          ? Colors.grey[700]
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      label: 'Gallery',
                      labelStyle: const TextStyle(fontSize: 15.0),
                      onTap: () => print('SECOND CHILD'),
                      onLongPress: () => print('SECOND CHILD LONG PRESS'),
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.add_link_outlined),
                      foregroundColor: Colors.white,
                      backgroundColor: Provider.of<ThemeManager>(context).isDark
                          ? Colors.grey[700]
                          : Colors.blue,
                      label: 'URL',
                      labelStyle: const TextStyle(
                        fontSize: 15.0,
                        backgroundColor: Colors.transparent,
                      ),
                      onTap: () => print('THIRD CHILD'),
                      onLongPress: () => print('THIRD CHILD LONG PRESS'),
                    ),
                    SpeedDialChild(
                      //speed dial child
                      child: const Icon(
                        Icons.add_business_rounded,
                      ),
                      backgroundColor: Provider.of<ThemeManager>(context).isDark
                          ? Colors.grey[700]
                          : Colors.blue,
                      foregroundColor: Colors.white,
                      label: 'Shop',
                      labelStyle: const TextStyle(
                        fontSize: 15.0,
                      ),
                      onTap: () {},
                      onLongPress: () => print('FIRST CHILD LONG PRESS'),
                    ),
                  ],
          ),
        ),
      );
    } else if (activeIndex == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: SpeedDial(
          useRotationAnimation: true,
          mini: false,
          spacing: 10.0,
          // animationAngle: 0.0,
          tooltip: 'Add to your wardrobe',
          heroTag: 'hero tag',
          animationCurve: Curves.elasticInOut,
          // animatedIconTheme: IconThemeData(size: 22.0),
          animationDuration: const Duration(milliseconds: 120),
          curve: Curves.easeIn,
          direction: SpeedDialDirection.up,
          renderOverlay: true,
          icon: Icons.menu,
          // icon: Transform.rotate(
          //   child: Icons.close,
          //   angle: -math.pi / 4,
          // ), //icon on Floating action button
          activeIcon: Icons.close, //icon when menu is expanded on button
          backgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.blueGrey
              : Colors.blueGrey, //background color of button
          foregroundColor: Colors.white, //font color, icon color in button
          activeBackgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.red[400]
              : Colors.red[400], //background color when menu is expanded
          activeForegroundColor: Colors.white,
          buttonSize: const Size(56.0, 56.0), //button size
          visible: true,
          closeManually: false,
          overlayColor: null,
          overlayOpacity: 0,
          onOpen: () => print('OPENING DIAL'), // action when menu opens
          onClose: () => print('DIAL CLOSED'), //action when menu closes
          elevation: 10.0, //shadow elevation of button
          shape: const CircleBorder(), //shape of button

          children: [
            SpeedDialChild(
              child: const Icon(Icons.book),
              foregroundColor: Colors.black,
              backgroundColor: Provider.of<ThemeManager>(context).isDark
                  ? Colors.grey[700]
                  : Colors.grey[50],
              label: 'Suggest a lookbook',
              labelStyle: const TextStyle(
                  fontSize: 15.0, backgroundColor: Colors.transparent),
              onTap: () => print('THIRD CHILD'),
              onLongPress: () => print('THIRD CHILD LONG PRESS'),
            ),
          ],
        ),
      );
    } else if (activeIndex == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: SpeedDial(
          useRotationAnimation: true,
          mini: false,
          spacing: 10.0,
          // animationAngle: 0.0,
          tooltip: 'Add to your wardrobe',
          heroTag: 'hero tag',
          animationCurve: Curves.elasticInOut,
          // animatedIconTheme: IconThemeData(size: 22.0),
          animationDuration: const Duration(milliseconds: 120),
          curve: Curves.easeIn,
          direction: SpeedDialDirection.up,
          renderOverlay: true,
          icon: Icons.add,
          // icon: Transform.rotate(
          //   child: Icons.close,
          //   angle: -math.pi / 4,
          // ), //icon on Floating action button
          activeIcon: Icons.close, //icon when menu is expanded on button
          backgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.blue
              : Colors.blue, //background color of button
          foregroundColor: Colors.white, //font color, icon color in button
          activeBackgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.red[400]
              : Colors.red[400], //background color when menu is expanded
          activeForegroundColor: Colors.white,
          buttonSize: const Size(56.0, 56.0), //button size
          visible: true,
          closeManually: false,
          overlayColor: null,
          overlayOpacity: 0.0,
          onOpen: () => print('OPENING DIAL'), // action when menu opens
          onClose: () => print('DIAL CLOSED'), //action when menu closes
          elevation: 10.0, //shadow elevation of button
          shape: const CircleBorder(), //shape of button

          children: const [],
        ),
      );
    } else {
      // TODO return an image of the logo as the FAB
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Maybe find a way to keep page view navigation
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: Scaffold(
        // Stops the FloatingActionButton from moving up with the keyboard
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          // child: pages[activeIndex].keys.first,
          child: PageStorage(
            bucket: bucket,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: pages[activeIndex].keys.first,
            ),
          ),
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     print('from home screen navigator');
        //     await Navigator.push(
        //       context,
        //       CupertinoPageRoute(
        //         builder: (context) {
        //           // final userContext = UserContext.of(context);
        //           return WardrobeScreen(uid: widget.uid!);
        //         },
        //       ),
        //     );
        //   },
        // ),
        floatingActionButton: _getFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          elevation: 5.0,
          // https://github.com/flutter/flutter/issues/49973
          shape: const CircularNotchedRectangle(convex: true),
          notchMargin: 5,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      minWidth: 40.0,
                      onPressed: () {
                        setState(() {
                          activeIndex = 0;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            const IconData(0xe248, fontFamily: 'MaterialIcons'),
                            color: activeIndex == 0 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Explore',
                            style: TextStyle(
                                color: activeIndex == 0
                                    ? Colors.blue
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40.0,
                      onPressed: () {
                        setState(() {
                          activeIndex = 1;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.door_sliding_rounded,
                            color: activeIndex == 1 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Wardrobe',
                            style: TextStyle(
                                color: activeIndex == 1
                                    ? Colors.blue
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Left tab bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MaterialButton(
                      minWidth: 40.0,
                      onPressed: () {
                        setState(() {
                          activeIndex = 2;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            const IconData(0xf7c4, fontFamily: 'MaterialIcons'),
                            color: activeIndex == 2 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Look Books',
                            style: TextStyle(
                                color: activeIndex == 2
                                    ? Colors.blue
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      minWidth: 40.0,
                      onPressed: () {
                        setState(() {
                          activeIndex = 3;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: activeIndex == 3 ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                                color: activeIndex == 3
                                    ? Colors.blue
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Left tab bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
