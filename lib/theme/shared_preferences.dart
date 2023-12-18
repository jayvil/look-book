import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _kNotificationsPrefs = "allowNotifications";
  static const String _kSortingOrderPrefs = "sortOrder";
  static const String _kDarkModePrefs = 'darkMode';

  static Future<bool> getAllowsNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kNotificationsPrefs) ?? false;
  }

  static Future<bool> setAllowsNotifications(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kNotificationsPrefs, value);
  }

  static Future<String> getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kSortingOrderPrefs) ?? 'name';
  }

  static Future<bool> setSortingOrder(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kSortingOrderPrefs, value);
  }

  static Future<bool> getThemePref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kDarkModePrefs) ?? false;
  }

  static Future<bool> setThemePref(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(_kDarkModePrefs, value);
  }
}
