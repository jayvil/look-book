import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_lookbook/colors.dart';

import '../components/gradient_button.dart';
import '../components/gradient_text.dart';
import 'email_login_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const Center(child: Text('Create your own digital closet')),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: height * .05,
                  width: width * .9,
                  child: GradientButton(
                    text: 'Continue',
                    onPressed: () {},
                    color1: kColorLightPurple,
                    color2: kColorLightBlue,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                InkWell(
                    child: const GradientText(
                      style: TextStyle(fontSize: 15),
                      gradient: LinearGradient(colors: [
                        kColorLightBlue,
                        kColorLightPurple,
                      ]),
                      text: 'Sign in',
                    ),
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const EmailLoginScreen(
                              // themeManager: widget.themeManager,
                              ),
                        ), //EmailLogIn()),
                      );
                    }),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
