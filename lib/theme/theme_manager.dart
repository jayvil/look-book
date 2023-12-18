import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://www.youtube.com/watch?v=LpCbUoahiww
class ThemeManager extends ChangeNotifier {
  late ThemeData _selectedTheme;

  ThemeData light = ThemeData.light().copyWith(
    // brightness: Brightness.light,
    // primaryColor: Colors.green,
    // appBarTheme: const AppBarTheme(
    //   color: Colors.green,
    //   shadowColor: Colors.black,
    //   actionsIconTheme: IconThemeData(),
    // ),
    // primaryIconTheme: IconThemeData(),
    // primaryTextTheme: TextTheme(),
    scaffoldBackgroundColor: const Color(0xffe5e1e1),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedLabelStyle: const TextStyle(
        color: Colors.lightBlue,
        letterSpacing: .3,
      ),
      selectedIconTheme: const IconThemeData(
        color: Colors.lightBlue,
        size: 30.0,
      ),
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.grey[700],
    ),
  );

  ThemeData dark = ThemeData.dark().copyWith(
    // fontFamily: 'Poppins',
    // brightness: Brightness.dark,
    // primaryColor: Colors.black,
    // canvasColor: Colors.black,
    // backgroundColor: Colors.black,
    // scaffoldBackgroundColor: Colors.black,
    scaffoldBackgroundColor: const Color(0xff0c0c0f),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white70,
      // color: Colors.green,
      // systemOverlayStyle: SystemUiOverlayStyle.light
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.green,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff252525),
      selectedItemColor: Colors.blue,
      selectedLabelStyle: TextStyle(
        color: Colors.blue,
        letterSpacing: .3,
      ),
      selectedIconTheme: IconThemeData(
        color: Colors.blue,
        size: 30.0,
      ),
      // type: BottomNavigationBarType.shifting,
      unselectedItemColor: Colors.white70,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ), bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
  );

  ThemeManager({required bool isDarkMode}) {
    _selectedTheme = isDarkMode ? dark : light;
  }

  ThemeData get getTheme => _selectedTheme;

  bool get isDark => _selectedTheme == dark;

  toggleTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isDark) {
      _selectedTheme = dark;
      prefs.setBool('isDarkTheme', true);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.black,
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
        ),
      );
    } else {
      _selectedTheme = light;
      prefs.setBool('isDarkTheme', false);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarDividerColor: Colors.black,
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
        ),
      );
    }
    notifyListeners();
  }
}
