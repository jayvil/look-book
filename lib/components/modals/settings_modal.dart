import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_lookbook/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../screens/welcome_page.dart';

class SettingsModal extends StatefulWidget {
  // final ThemeManager themeManager;
  const SettingsModal({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsModalState();
}

// ThemeManager _themeManager = ThemeManager();

class _SettingsModalState extends State<SettingsModal> {
  bool darkModeVal = false;
  late bool? anonUser;
  @override
  void dispose() {
    // widget.themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    // widget.themeManager.addListener(themeListener);
    super.initState();
    anonUser = FirebaseAuth.instance.currentUser?.isAnonymous;
  }

  themeListener() {
    if (mounted) {
      setState(() {
        print('settings modal set state');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Material(
    //     child: CupertinoPageScaffold(
    //   navigationBar: CupertinoNavigationBar(
    //     leading: Container(),
    //     middle: Text('Settings'),
    //   ),
    //   child: Center(),
    // ));
    return Container(
      // color: Theme.of(context).colorScheme.secondary,
      // height: 400.0,
      child: SettingsList(
        // platform: DevicePlatform.iOS,
        // applicationType: ApplicationType.material,
        shrinkWrap: false,
        sections: [
          SettingsSection(
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 15.0),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) {},
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.format_paint),
                title: const Text('Dark Mode'),
                onToggle: (bool value) {
                  print('on toggle');
                  ThemeManager themeProvider =
                      Provider.of<ThemeManager>(context, listen: false);
                  if (themeProvider.getTheme == themeProvider.light) {
                    themeProvider.toggleTheme(true);
                  } else {
                    themeProvider.toggleTheme(false);
                  }
                  setState(() {});
                },
                onPressed: (context) {
                  setState(() {
                    print('on pressed');
                    darkModeVal = false;
                  });
                },
                enabled: true,
                initialValue: Provider.of<ThemeManager>(context).isDark,
              ),
              SettingsTile.switchTile(
                activeSwitchColor: Colors.blue,
                enabled: true,
                onToggle: (value) {},
                initialValue: false,
                leading: const Icon(Icons.pin),
                title: const Text('Pin Lock'),
              ),
              SettingsTile(
                leading: const Icon(Icons.numbers),
                title: const Text('Version'),
                value: const Text('0.0.1'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Account information'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Public profile'),
              )
            ],
          ),
          SettingsSection(
              title: const Text('Actions'),
              tiles: anonUser != null && anonUser == true
                  ? [
                      SettingsTile.navigation(
                        title: const Text('Sign up'),
                        onPressed: (context) {
                          // TODO https://firebase.google.com/docs/auth/android/anonymous-auth?authuser=1&hl=en
                        },
                      )
                    ]
                  : [
                      SettingsTile.navigation(
                        title: const Text('Log out'),
                        onPressed: (context) {
                          User? user = FirebaseAuth.instance.currentUser;
                          FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                      )
                    ]
              // [
              //   SettingsTile.navigation(
              //     title: const Text('Log out'),
              //     onPressed: (context) {
              //       User? user = FirebaseAuth.instance.currentUser;
              //       FirebaseAuth.instance.signOut();
              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         CupertinoPageRoute(
              //           builder: (context) => const WelcomePage(),
              //         ),
              //         (Route<dynamic> route) => false,
              //       );
              //     },
              //   )
              // ],
              ),
          SettingsSection(
            title: const Text('Support'),
            tiles: [
              SettingsTile(
                title: const Text('See terms of service'),
              ),
              SettingsTile(
                title: const Text('See privacy policy'),
              )
            ],
          )
        ],
      ),
    );
  }
}
