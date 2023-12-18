import 'package:flutter/material.dart';

class ClothingCard extends StatefulWidget {
  const ClothingCard({super.key});

  @override
  State<ClothingCard> createState() => _ClothingCardState();
}

class _ClothingCardState extends State<ClothingCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.red,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: Image.network(
          'https://placeimg.com/640/480/any',
          height: 80,
          width: 80,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
