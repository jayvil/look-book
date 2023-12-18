import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_lookbook/components/gradient_button.dart';
import 'package:my_lookbook/screens/navigation_screen.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../components/gradient_text.dart';
import '../theme/theme_manager.dart';
import 'email_signup_screen.dart';

// TODO https://www.youtube.com/watch?v=idJDAdn_jKk
// TODO Launcher icons https://www.youtube.com/watch?v=eMHbgIgJyUQ
// TODO add login transition animation https://stackoverflow.com/questions/50196913/how-to-change-navigation-animation-using-flutter
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  // final ThemeManager themeManager;
  @override
  _EmailLoginScreenState createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late UserCredential userCredential;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            // leading: Icon(
            //   Icons.chevron_left,
            //   size: 30.0,
            //   color: Provider.of<ThemeManager>(context).isDark
            //       ? Colors.white
            //       : Colors.black,
            // ),
          ),
          backgroundColor: Colors.grey[200],
          // appBar: AppBar(title: Text("Login")),
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Look Book',
                  style: GoogleFonts.poppins(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 70,
                    color: kColorTitle,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              SizedBox(
                width: width * .8,
                height: height * .45,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  elevation: 1,
                  shadowColor: Provider.of<ThemeManager>(context).isDark
                      ? Colors.white
                      : Colors.black,
                  color: Provider.of<ThemeManager>(context).isDark
                      ? Colors.grey[900]
                      : Colors.white,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Log in',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context).textTheme.headlineMedium,
                            fontSize: 30,
                            color: kColorTitle,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Enter Email Address",
                              // enabledBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(20.0),
                              // ),
                              border: UnderlineInputBorder(),
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Email Address';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email address!';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: "Enter Password",
                              // enabledBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(20.0),
                              // ),
                              border: UnderlineInputBorder(),
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Password';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters!';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                                  height: height * .05,
                                  width: width * .9,
                                  child: GradientButton(
                                    color1: const Color(0xff9E7FFF),
                                    color2: const Color(0xff7287F5),
                                    text: 'Sign in',
                                    onPressed: () {},
                                  ),
                                ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                          child: InkWell(
                            child: const GradientText(
                              style: TextStyle(fontSize: 15),
                              gradient: LinearGradient(colors: [
                                kColorLightBlue,
                                kColorLightPurple,
                              ]),
                              text: 'Forgot password?',
                            ),
                            onTap: () {
                              HapticFeedback.heavyImpact();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 50.0, right: 15.0),
                        child: const Divider(
                          color: Colors.black,
                          height: 50,
                        )),
                  ),
                  Text(
                    "OR",
                    style: GoogleFonts.poppins(
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      fontSize: 12,
                      color: kColorTitle,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 15.0, right: 50.0),
                        child: const Divider(
                          color: Colors.black,
                          height: 50,
                        )),
                  ),
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: height * .05,
                        width: width * .9,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.grey[900]
                                  : Colors.grey[300],
                              padding: const EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enableFeedback: true),
                          onPressed: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                child: Icon(
                                  FontAwesomeIcons.google,
                                  size: 20,
                                  color:
                                      Provider.of<ThemeManager>(context).isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[900],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                child: Text('Continue with Google',
                                    style: TextStyle(
                                      color: Provider.of<ThemeManager>(context)
                                              .isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[900],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                      child: SizedBox(
                        height: height * .05,
                        width: width * .9,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.grey[900]
                                  : Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enableFeedback: true),
                          onPressed: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.apple,
                                color: Provider.of<ThemeManager>(context).isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[900],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  'Continue with Apple',
                                  style: TextStyle(
                                    color: Provider.of<ThemeManager>(context)
                                            .isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      child: const GradientText(
                        style: TextStyle(fontSize: 15),
                        gradient: LinearGradient(colors: [
                          kColorLightBlue,
                          kColorLightPurple,
                        ]),
                        text: 'Continue with email',
                      ),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const EmailSignUpScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                    child: GradientButton(
                      color1: kColorLightPurple,
                      color2: kColorLightBlue,
                      text: "I'll look around first",
                      // TODO https://firebase.flutter.dev/docs/auth/anonymous-auth/
                      onPressed: () async {
                        try {
                          anonSignin(context, () {
                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => NavigationScreen(
                                    user: userCredential.user!,
                                    activeIndex: 0,
                                  ),
                                ),
                              );
                            }
                          });
                          print("Signed in with temporary account.");
                        } on FirebaseAuthException catch (e) {
                          switch (e.code) {
                            case "operation-not-allowed":
                              print(
                                  "Anonymous auth hasn't been enabled for this project.");
                              break;
                            default:
                              print("Unknown error.");
                          }
                        }
                      },
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

  Future<void> anonSignin(BuildContext context, VoidCallback onSuccess) async {
    userCredential = await FirebaseAuth.instance.signInAnonymously();
    onSuccess.call();
  }

  void logInToFb() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      print(result.user!.displayName);

      isLoading = false;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => NavigationScreen(
            user: result.user!,
            // themeManager: widget.themeManager,
          ),
        ),
      );
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(err.message),
              actions: [
                ElevatedButton(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
