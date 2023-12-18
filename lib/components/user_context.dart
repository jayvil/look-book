import 'package:flutter/material.dart';

class UserContext extends InheritedWidget {
  const UserContext({
    super.key,
    required this.uid,
    required child,
  }) : super(
          child: child,
        );
  final String uid;

  static UserContext of(BuildContext context) {
    final UserContext? result =
        context.dependOnInheritedWidgetOfExactType<UserContext>();
    assert(result != null, 'No UserContext found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(UserContext oldWidget) => uid != oldWidget.uid;
}
