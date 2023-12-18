
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

// https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
// TODO: https://flutterawesome.com/a-simple-pull-down-refresh-and-pull-up-loading-with-flutter/
// TODO: https://dev.to/aouahib/build-a-flutter-gallery-to-display-all-the-photos-and-videos-in-your-phone-pb6
// TODO: https://pub.dev/packages/flutter_dropdown_alert

class HomeScreen extends StatefulWidget {
  final String? uid;
  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _pinned = true;
  final bool _snap = false;
  final bool _floating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: Scaffold(
        backgroundColor: Provider.of<ThemeManager>(context).isDark
            ? Colors.black
            : Colors.white,
        drawer: Drawer(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            // topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(40.0),
          )),
          // backgroundColor: const Color(0xff1A1A1E),
          elevation: 1.0,
          // 65% of screen will be occupied
          width: MediaQuery.of(context).size.width * .5,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                    // color: Color(0xff1A1A1E),
                    ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                leading: const Icon(Icons.analytics_rounded),
                title: const Text('Wardrobe Analytics'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cut),
                title: const Text('Clipper Tool'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Clothing Suggestions'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.luggage_rounded),
                title: const Text('Packing Lists'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.face),
                title: const Text('Style Tips and Tricks'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.face),
                title: const Text('Mood Board'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        //     FlexibleSpaceBar(
        //   // title: Text('SliverAppBar'),
        //   background: Container(
        //     color: Colors.black,
        //   ),
        // ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0.0,
              pinned: _pinned,
              snap: _snap,
              floating: _floating,
              backgroundColor: Provider.of<ThemeManager>(context).isDark
                  ? Colors.black
                  : Colors.white,
              // backgroundColor: const Color(0xff141D26),
              expandedHeight: 100.0,
              shape: const Border(
                  bottom: BorderSide(
                width: 0,
                color: Colors.transparent,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
