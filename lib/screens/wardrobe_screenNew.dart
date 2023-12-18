import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_lookbook/providers/blur_provider.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../db/db.dart';
import '../theme/theme_manager.dart';

// TODO: https://medium.flutterdevs.com/selecting-multiple-item-in-list-in-flutter-811a3049c56f
// multiselect to delete

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  bool showBlur = false;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = GoogleFonts.poppins(
      textStyle: Theme.of(context).textTheme.bodyLarge,
      fontSize: 30,
      color: kColorTitle,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Future<List<Map<String, dynamic>>> clothingItemIds =
        DB.rawQuery('SELECT * FROM wardrobe');
    print('image path list $clothingItemIds');
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('New Wardrobe Screen'),
            ),
            body: SingleChildScrollView(
              child: ImageFiltered(
                  imageFilter: context.watch<Blur>().blur
                      ? ImageFilter.blur(sigmaY: 4, sigmaX: 4)
                      : ImageFilter.blur(),
                  child: Column(
                    children: [
                      // Load items from database
                      FutureBuilder(
                        future: clothingItemIds,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          print(snapshot.data.toString() == '[]');
                          if (!snapshot.hasData) {
                            print(snapshot.data);
                            print('no data');
                            return Container(
                              child: Text('snapshot data $snapshot'),
                            );
                          } else {
                            if (!snapshot.hasData || snapshot.data.toString() == '[]') {
                              // if(!snapshot.hasData) {
                              //   print('no wardrobe data: ${snapshot.data}');
                              // }
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '  Oh no, an empty wardrobe!',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/wardrobe_empty.svg',
                                      semanticsLabel: 'An empty wardrobe',
                                      width: width * .4,
                                      height: height * .4,
                                    ),
                                    Text(
                                      'Add clothes to your wardrobe to get started',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: GridView.extent(
                                  // crossAxisCount: 5,
                                  crossAxisSpacing: 2.0,
                                  mainAxisSpacing: 2.0,
                                  shrinkWrap: true,
                                  childAspectRatio: width / height,
                                  maxCrossAxisExtent: 90.0,
                                  children: [
                                    for (var item in snapshot.data!)
                                      Image.file(
                                        File(
                                          item['image_path'].toString(),
                                        ),
                                        fit: BoxFit.cover,
                                        // width: 100,
                                        // height: 100,
                                        errorBuilder: (
                                          BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey,
                                            width: 100,
                                            height: 100,
                                            child: const Center(
                                              child: Text(
                                                  'Error load image',
                                                  textAlign: TextAlign.center),
                                            ),
                                          );
                                        },
                                        filterQuality: FilterQuality.low,
                                      )
                                  ],
                                ),
                              );
                            }
                          }
                          // // if (snapshot.hasData) {
                          // if (snapshot.connectionState ==
                          //         ConnectionState.waiting &&
                          //     snapshot.hasData) {
                          //   print('empty data');
                          //   return const Center(
                          //       child: CircularProgressIndicator());
                          // }
                          // if (snapshot.connectionState ==
                          //     ConnectionState.done) {
                          //   if (snapshot.data) {

                          //   } else {

                          //   }
                          // } else {
                          //   return CircularProgressIndicator();
                          // }
                        },
                      ),
                      // TODO load items from firebase
                    ],
                  )),
            )),
      ),
    );
  }
}
