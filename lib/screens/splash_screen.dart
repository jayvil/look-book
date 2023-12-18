import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_lookbook/screens/navigation_screen.dart';
import 'package:my_lookbook/screens/welcome_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

//

class LookbookSplashScreen extends StatefulWidget {
  const LookbookSplashScreen({super.key});
  // final ThemeManager themeManager;
  @override
  State<LookbookSplashScreen> createState() => _LookbookSplashScreenState();
}

class _LookbookSplashScreenState extends State<LookbookSplashScreen> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    print(user?.uid.toString());
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: AnimatedSplashScreen(
        // backgroundColor: ,
        duration: 1200,
        splash: Image.asset(
          'lib/images/flame-space-adventures-animated.gif',
          // width: 0,
          // height: 0,
          fit: BoxFit.contain,
        ),
        splashIconSize: 500.0,
        nextScreen: user != null
            ? NavigationScreen(
                user: user,
                activeIndex: 0,
                // themeManager: widget.themeManager,
              )
            // : SignUpScreen(
            //     // themeManager: widget.themeManager,
            //     ),
            : const WelcomePage(),
        pageTransitionType: PageTransitionType.bottomToTop,
        // backgroundColor: const Color(0xff1C1C21),
      ),
    );
  }
}
