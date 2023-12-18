import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';
import 'clothing_card.dart';

class WardrobeCategoryRow extends StatefulWidget {
  WardrobeCategoryRow(
      {super.key,
      required this.categoryName,
      required this.clothingCardsList,
      required this.onCategoryNamePressed});
  final String categoryName;
  List<ClothingCard> clothingCardsList;
  final Function() onCategoryNamePressed;

  @override
  State<WardrobeCategoryRow> createState() => _WardrobeCategoryRowState();
}

class _WardrobeCategoryRowState extends State<WardrobeCategoryRow> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
          child: Row(
            children: [
              TextButton(
                onPressed: widget.onCategoryNamePressed,
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  enableFeedback: true,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.categoryName),
                    const SizedBox(
                      width: 1,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Add button for the row
            Card(
              shadowColor: Provider.of<ThemeManager>(context).isDark
                  ? Colors.white
                  : Colors.black,
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: IconButton(
                iconSize: height * .11,
                icon: Icon(
                  Icons.add_circle_rounded,
                  size: 30.0,
                  color: Colors.grey[400],
                ),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: Scrollbar(
                interactive: true,
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.clothingCardsList,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
