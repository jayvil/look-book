import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  // final ThemeManager themeManager;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Clothing App'), //widget.title),
        // ),
        extendBodyBehindAppBar: true,
        backgroundColor: Provider.of<ThemeManager>(context).isDark
            ? Colors.black
            : Colors.grey[100],
        body: Center(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            elevation: 50,
            shadowColor: Provider.of<ThemeManager>(context).isDark
                ? Colors.white
                : Colors.black,
            color: Provider.of<ThemeManager>(context).isDark
                ? Colors.grey[900]
                : Colors.lightBlue,
            child: SizedBox(
              width: 250,
              height: 300,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text("",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                fontFamily: 'Roboto')),
                      ),
                      // Padding(
                      //     padding: EdgeInsets.all(0.0),
                      //     child:
                      //     SignInButton(
                      //       Buttons.Email,
                      //       shape: StadiumBorder(),
                      //       text: "Continue with Email",
                      //       onPressed: () {
                      //         Navigator.push(
                      //           context,
                      //           CupertinoPageRoute(
                      //             builder: (context) =>
                      //                 const EmailSignUpScreen(),
                      //           ),
                      //         );
                      //       },
                      //     )),
                      //     padding: EdgeInsets.all(0.0),
                      //     child:
                      //     SignInButton(
                      //       Buttons.Email,
                      //       shape: StadiumBorder(),
                      //       text: "Continue with Email",
                      //       onPressed: () {
                      //         Navigator.push(
                      //           context,
                      //           CupertinoPageRoute(
                      //             builder: (context) =>
                      //                 const EmailSignUpScreen(),
                      //           ),
                      //         );
                      //       },
                      //     )),
                      // Padding(
                      //   padding: EdgeInsets.all(0.0),
                      //   child: SignInButton(
                      //     Provider.of<ThemeManager>(context).isDark
                      //         ? Buttons.Google
                      //         : Buttons.GoogleDark,
                      //     shape: const StadiumBorder(),
                      //     text: "Continue with Google",
                      //     onPressed: () {},
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child:
                            // SignInButton(
                            //   Provider.of<ThemeManager>(context).isDark
                            //       ? Buttons.Apple
                            //       : Buttons.AppleDark,
                            //   shape: StadiumBorder(),
                            //   text: "Continue with Apple",
                            //   onPressed: () {},
                            // ),
                            ElevatedButton(
                          onPressed: () {},
                          child: const Row(
                            children: [
                              Icon(FontAwesomeIcons.google),
                              Text('Continue with Google'),
                            ],
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.all(10.0),
                      //   child: InkWell(
                      //       child: Text("Already have an account? Sign in",
                      //           style: TextStyle(
                      //             // decoration: TextDecoration.underline,
                      //             color:
                      //                 Provider.of<ThemeManager>(context).isDark
                      //                     ? Colors.white
                      //                     : Colors.black,
                      //           )),
                      //       onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           CupertinoPageRoute(
                      //             builder: (context) => const EmailLoginScreen(
                      //                 // themeManager: widget.themeManager,
                      //                 ),
                      //           ), //EmailLogIn()),
                      //         );
                      //       }),
                      // )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
