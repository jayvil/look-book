import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../components/modals/settings_modal.dart';
import '../theme/theme_manager.dart';

// https://github.com/jamesblasco/modal_bottom_sheet/tree/main/modal_bottom_sheet/example/lib/modals
// https://stackoverflow.com/questions/60232070/how-to-implement-dark-mode-and-light-mode-in-flutter
// https://rrtutors.com/tutorials/flutter-profile-page-ui
// https://pub.dev/packages/modal_bottom_sheet
// https://github.com/Baseflow/flutter-permission-handler/blob/master/permission_handler/example/android/app/src/main/AndroidManifest.xml

// ThemeManager _themeManager = ThemeManager();

class AccountScreen extends StatefulWidget {
  final User? user;
  // final ThemeManager themeManager;
  const AccountScreen({super.key, required this.user});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final bool _pinned = true;
  final bool _snap = false;
  final bool _floating = false;
  bool darkModeVal = false;
  @override
  void dispose() {
    // _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    // _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // initialise the provider class
    // final appTheme = Provider.of<ButtonTapListener>(context);
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
          // backgroundColor: appTheme.isClicked
          //     ? Theme.of(context).primaryColorDark
          //     : Theme.of(context).primaryColorLight,
          appBar: AppBar(
            // backgroundColor: const Color(0xff232329),
            backgroundColor: Colors.black,
            elevation: 0.0,
            actions: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(FontAwesomeIcons.share),
              ),
              IconButton(
                onPressed: () {
                  showBarModalBottomSheet(
                    barrierColor: Colors.black45,
                    context: context,
                    bounce: true,
                    builder: (context) => SizedBox(
                      // color: Provider.of<ThemeManager>(context).isDark
                      //     ? const Color(0xff141D26)
                      //     : Colors.white,
                      height: 250.0,
                      child: SettingsList(
                        platform: DevicePlatform.iOS,
                        applicationType: ApplicationType.material,
                        shrinkWrap: false,
                        darkTheme: const SettingsThemeData(
                          settingsSectionBackground: Colors.black,
                          settingsListBackground: Colors.black,
                          dividerColor: Colors.grey,
                        ),
                        lightTheme: SettingsThemeData(
                          settingsSectionBackground: Colors.grey[200],
                          settingsListBackground: Colors.grey[200],
                          dividerColor: Colors.grey[400],
                        ),
                        sections: [
                          SettingsSection(
                            title: const Text(
                              'Profile',
                              style: TextStyle(fontSize: 15.0),
                            ),
                            tiles: <SettingsTile>[
                              SettingsTile.navigation(
                                leading: const Icon(Icons.person),
                                title: const Text('Edit public profile'),
                              ),
                              SettingsTile(
                                leading: const Icon(Icons.share),
                                title: const Text('Share profile'),
                                onPressed: null,
                              ),
                              SettingsTile.navigation(
                                leading: const Icon(Icons.settings),
                                title: const Text(
                                  'Settings',
                                  style: TextStyle(
                                      // fontSize: 15.0,
                                      ),
                                ),
                                onPressed: (context) {
                                  Navigator.pop(context);
                                  showBarModalBottomSheet(
                                      barrierColor: Colors.black45,
                                      context: context,
                                      expand: true,
                                      bounce: true,
                                      builder: (context) => const SettingsModal());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 350.0,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100.0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          widget.user!.toString(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
