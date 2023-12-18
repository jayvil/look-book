import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.color1,
      required this.color2});
  final String text;
  final Function() onPressed;
  final Color color1;
  final Color color2;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onPressed,
      child: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              color1,
              color2,
            ]),
            borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: height * .05,
          width: width * .9,
          alignment: Alignment.center,
          child: Text(text),
        ),
      ),
    );
  }
}
