import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_lookbook/screens/navigation_screen.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

class EmailSignUpScreen extends StatefulWidget {
  // final ThemeManager themeManager;

  const EmailSignUpScreen({super.key});

  @override
  _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseDatabase fbDb = FirebaseDatabase.instance;
  FirebaseFirestore fbFs = FirebaseFirestore.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  // TextEditingController ageController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    nameController.dispose();
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
            // appBar: AppBar(title: Text("Sign Up")),
            backgroundColor: Provider.of<ThemeManager>(context).isDark
                ? const Color(0xff1C1C21)
                : Colors.white,
            body: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    const Center(
                      child: Text('HELLO THERE'),
                    ),
                    const Center(
                      child: Text('Register below with your details!'),
                    ),
                    // First Name
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: firstNameController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: passwordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.text_fields_rounded,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "First Name",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter User Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Last Name
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: lastNameController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: passwordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.text_fields_rounded,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "Last Name",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter User Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Email
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: emailController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: passwordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter an Email Address';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Username
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: userNameController,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: passwordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.person,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "User Name",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a User Name';
                          }
                          // TODO: Check if Username exists
                          return null;
                        },
                      ),
                    ),
                    // Password
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        focusNode: passwordFocusNode,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        cursorColor: Provider.of<ThemeManager>(context).isDark
                            ? Colors.blue
                            : Colors.blue,
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: passwordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.password_rounded,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Password';
                          } else if (value.length < 6) {
                            return 'Password must be atleast 6 characters!';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Confirm password
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        focusNode: confirmPasswordFocusNode,
                        style: TextStyle(
                          fontSize: 18,
                          color: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        cursorColor: Provider.of<ThemeManager>(context).isDark
                            ? Colors.blue
                            : Colors.blue,
                        obscureText: true,
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          focusColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          floatingLabelStyle: TextStyle(
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          labelStyle: TextStyle(
                            color: confirmPasswordFocusNode.hasFocus &
                                    Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          // add prefix icon
                          prefixIcon: Icon(
                            Icons.password_rounded,
                            color: Provider.of<ThemeManager>(context).isDark
                                ? Colors.grey[400]
                                : Colors.grey,
                          ),
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Provider.of<ThemeManager>(context).isDark
                              ? Colors.white
                              : Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.blue
                                  : Colors.blue,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeManager>(context).isDark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.0,
                            ),
                          ),
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a password to confirm';
                          } else if (value.length < 6) {
                            return 'Passwords must match';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Submit button
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              height: height * .05,
                              width: width * .9,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        StadiumBorder>(
                                      const StadiumBorder(),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blue)),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    registerToFirebase();
                                  }
                                },
                                child: const Text('Sign up'),
                              ),
                            ),
                    )
                  ]),
                ),
              ),
            )),
      ),
    );
  }

  void registerToFirebase() {
    // TODO Confirm password and username availability before creating user
    // Create user
    firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((result) {
      // TODO result.user.sendEmailVerification()
      // TODO result.user.updatePhoneNumber and have option for email or phone verification to reset password

      result.user?.updateDisplayName(userNameController.text);
      result.user?.updateEmail(emailController.text);

      fbDb.ref("users").child(result.user!.uid).set({
        // Add user details
        "email": emailController.text,
        'username': userNameController.text,
        "fullname": nameController.text,
        'displayName': userNameController.text,
      }).then((res) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => NavigationScreen(
              user: result.user!,
              activeIndex: 0,
            ),
          ),
        );
      });
      return result;
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
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
