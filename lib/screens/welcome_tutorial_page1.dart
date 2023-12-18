import 'package:flutter/material.dart';

class WelcomeTutorialPage1 extends StatefulWidget {
  const WelcomeTutorialPage1({super.key});

  @override
  State<WelcomeTutorialPage1> createState() => _WelcomeTutorialPage1State();
}

class _WelcomeTutorialPage1State extends State<WelcomeTutorialPage1> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: widget.welcomePage1Route,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    const welcomePage1Route = 'welcome_page_1';
    late Widget page;
    switch(settings.name){
      case welcomePage1Route:
        page = const WelcomeTutorialPage1();
    }
    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }
}
