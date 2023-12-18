import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:my_lookbook/db/db.dart';
import 'package:my_lookbook/firebase_options.dart';
import 'package:my_lookbook/providers/blur_provider.dart';
import 'package:my_lookbook/providers/edit_tool_provider.dart';
import 'package:my_lookbook/screens/splash_screen.dart';
import 'package:my_lookbook/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
Designing an algorithm to match clothes could involve several steps, such as:
Collecting data: Gather a large dataset of images of clothing items, along with information about the color, style, and type of each item.
Preprocessing: Perform image processing techniques such as resizing, cropping, and color correction to ensure that the images are of consistent quality and size.
Feature extraction: Extract features from the images such as color histograms, texture patterns, and shape information that can be used to represent the clothing items in a compact and informative way.
Clustering: Use unsupervised learning techniques such as k-means or hierarchical clustering to group the clothing items into clusters based on their feature representations.
Matching: For a given clothing item, find the closest cluster(s) and return the items from those clusters as potential matches.
User Feedback : Allow the user to rate the match suggestions, use this feedback to improve the matching algorithm.
Refining the algorithm: Use the feedback from the user to refine the algorithm and improve the accuracy of the matches over time.
Note: This is just an outline of a possible algorithm, and there are many variations and refinements that could be made depending on the specific requirements and constraints of the task.
* */

// https://medium.com/@afrozshaikh_/adding-android-12-stretch-effect-to-your-flutter-app-4352798faa3b
// https://medium.com/flutter-community/build-a-theme-manager-in-flutter-3faeed26b8b3
// https://docs.flutter.dev/cookbook/effects/nested-nav
// TODO: Create a nested navigation flow for the wardrobe page
// TODO: Remove microphone permissions
// TODO: Make fonts local to fix network dependence
// TODO: Implement a log to replace print statements and make a feature to generate a log to report issues
// TODO: https://www.kodeco.com/19430602-how-to-create-a-2d-snake-game-in-flutter
// TODO: https://www.kodeco.com/25237210-building-a-drawing-app-in-flutter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory current = Directory.current;
  print(current.absolute);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ThemeManager themeManager =
      ThemeManager(isDarkMode: prefs.getBool('isDarkTheme') ?? false);
  final androidVersionInfo = await DeviceInfoPlugin().androidInfo;
  final sdkVersion = androidVersionInfo.version.sdkInt ?? 0;
  final androidOverscrollIndicator = sdkVersion > 30
      ? AndroidOverscrollIndicator.stretch
      : AndroidOverscrollIndicator.glow;
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarDividerColor:
          themeManager.isDark ? Colors.black : Colors.white,
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // ensure that the Flutter app initializes properly while initializing the
  // database with await DB.init().
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  binding.renderView.automaticSystemUiAdjustment = false;
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  // ]);
  await Firebase.initializeApp(
    name: 'dev project',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
      // webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      );

  // token = await FirebaseMessaging.instance.getToken();
  // Provider.debugCheckInvalidValueType = null;
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  await DB.init();
  // return runApp(
  //   ChangeNotifierProvider(
  //     child: MyApp(
  //       androidOverscrollIndicator: androidOverscrollIndicator,
  //     ),
  //     create: (BuildContext context) => _themeManager,
  //   ),
  // );
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Blur>(create: (_) => Blur()),
        ChangeNotifierProvider(create: (BuildContext context) => themeManager),
        ChangeNotifierProvider<EditTool>(create: (_) => EditTool())
      ],
      child: MyApp(
        androidOverscrollIndicator: androidOverscrollIndicator,
      ),
      // create: (BuildContext context) => _themeManager,
    ),
  );
}

// Removes the overscroll indicator on the application
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.androidOverscrollIndicator = AndroidOverscrollIndicator.stretch,
  });
  final AndroidOverscrollIndicator androidOverscrollIndicator;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraDescription? firstCamera;
  List<CameraDescription> cameras = [];
  late Future<bool> themePref;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  initState() {
    setTheme();
    super.initState();
  }

  void setTheme() async {
    themePref = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('theme') ?? false;
    });
  }

  themeListener1() {
    if (mounted) {
      setState(() {
        print('main set state');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'I Look Good',
          theme: themeProvider.getTheme,
          builder: (context, child) => ScrollConfiguration(
            behavior: MyBehavior(),
            child: Stack(
              children: [
                child!,
                const DropdownAlert(),
              ],
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const LookbookSplashScreen(
              // themeManager: null,
              ),
        );
      },
    );
  }
}
