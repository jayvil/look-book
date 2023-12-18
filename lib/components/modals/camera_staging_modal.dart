import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_lookbook/components/clothing_info_form.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../colors.dart';
import '../../db/db.dart';
import '../../db/models.dart';
import '../../screens/photo_edit_screen.dart';

class CameraStagingModal extends StatefulWidget {
  const CameraStagingModal({super.key});

  @override
  State<CameraStagingModal> createState() => _CameraStagingModalState();
}

class _CameraStagingModalState extends State<CameraStagingModal> {
  final ImagePicker picker = ImagePicker();
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = GoogleFonts.poppins(
      textStyle: Theme.of(context).textTheme.bodyLarge,
      fontSize: 30,
      color: kColorTitle,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
    );

    Future<List<Map<String, dynamic>>> clothingImageList = DB.rawQuery(
        'SELECT image_path FROM clothing_item WHERE creation_datetime = (SELECT max(creation_datetime) FROM clothing_item)');
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    List<GlobalKey<FormState>> formKeys = [
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>()
    ];

    return SafeArea(
      child: SizedBox(
        height: height * .9,
        child: Scaffold(
          body: Column(
            children: [
              // const Expanded(child: SizedBox()),
              FutureBuilder(
                future: clothingImageList,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  // print(snapshot.data.toString() == '[]');
                  if (!snapshot.hasData) {
                    print('no data');
                    return const Expanded(
                      child: Column(
                        children: [
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (snapshot.data.toString() == '[]') {
                      return Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Expanded(child: SizedBox()),
                          Text(
                            'Recently added clothing items will show here',
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                          SvgPicture.asset(
                            'assets/images/empty_recents.svg',
                            semanticsLabel: 'An empty wardrobe',
                            width: width * .4,
                            height: height * .4,
                          ),
                          Text(
                            'after you start building your wardrobe',
                            style: textStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GridView.count(
                          crossAxisCount: 5,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                          shrinkWrap: true,
                          childAspectRatio: width / height,
                          children: buildPhotoWidgets(snapshot, context)!,
                        ),
                      );
                    }
                  }
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      child: const Icon(Icons.add_a_photo_rounded),
                      onPressed: () async {
                        XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          showCupertinoModalBottomSheet(
                            context: context,
                            builder: (context) => PhotoDetailsScreeen(
                              images: [image],
                            ),
                            enableDrag: false,
                            isDismissible: false,
                          );
                        }
                      }),
                  ElevatedButton(
                    onPressed: () async {
                      // Pick multiple images
                      final List<XFile> images = await picker.pickMultiImage();
                      if (images.isNotEmpty) {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => PhotoDetailsScreeen(
                            images: images,
                          ),
                          enableDrag: false,
                          isDismissible: false,
                        );
                      }
                    },
                    child: const Icon(Icons.add_photo_alternate_sharp),
                  ),
                  ElevatedButton(
                    onPressed: () async {},
                    child: const Icon(Icons.add_link_rounded),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      showBarModalBottomSheet(
                        overlayStyle: SystemUiOverlayStyle.light,
                        context: context,
                        builder: (context) => Container(),
                      );
                    },
                    child: const Icon(Icons.add_business_rounded),
                  ),
                  SizedBox(
                    height: height * .21,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget>? buildPhotoWidgets(snapshot, formKeys) {
  List<Image> children = [];
  for (var item in snapshot.data!) {
    var widget = Image.file(
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
            child: Text('Error load image', textAlign: TextAlign.center),
          ),
        );
      },
      filterQuality: FilterQuality.low,
    );
    children.add(widget);
    // formKeys.add(GlobalKey<FormState>());
  }
  return children;
}

class PhotoDetailsScreeen extends StatefulWidget {
  const PhotoDetailsScreeen({super.key, required this.images});
  final List<XFile> images;
  @override
  State<PhotoDetailsScreeen> createState() => _PhotoDetailsScreeenState();
}

class _PhotoDetailsScreeenState extends State<PhotoDetailsScreeen> {
  // List to hold each items details. List of <Category, details(dynamic)>
  final List<Map<String, dynamic>> itemDetails = [];
  final List<List<Map<String, dynamic>>> items = [];
  String? categoryDropdownValue;
  String? subCategoryDropdownValue;
  List<String> subCategoryDropDownList = [];
  List<String> dropDownList = [];
  late PermissionStatus _permissionStatus;
  final PageController _pageController = PageController();
  double currentPage = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _firstController = ScrollController();

  double cWidth = 0.0;
  double cHeight = 0.0;
  double itemHeight = 28.0;
  double itemsCount = 20;
  late double screenWidth;
  late double screenHeight;

  void buildItemDetails() {
    for (int i = 0; i < widget.images.length; i++) {
      Map<String, dynamic> newDetailItem = {
        'category': null,
        'color': null,
        'material': null,
        'pattern': null,
        'season': null,
        'brand': null,
        'size': null,
        'price': null,
        'date': null,
        'tags': null,
        'url': null,
        'notes': null,
        'isAvailable': null,
      };
      itemDetails.add(newDetailItem);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!;
      });
    });

    _scrollController.addListener(onScroll);
    buildItemDetails();
    // Load DB data into memory to use in saveItem()

    super.initState();
  }

  onScroll() {
    setState(() {
      cHeight =
          _scrollController.offset * screenHeight / (itemHeight * itemsCount);
    });
  }

  void saveClotingItem() async {
    // Get permission to use local storage
    // TODO Move storage permission request to better spot?
    () async {
      _permissionStatus = await Permission.storage.status;
      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
          print(_permissionStatus.toString());
        });
      }
    }();
    // TODO optimize linear save or sql statements?
    print(itemDetails);
    for (int i = 0; i < itemDetails.length; i++) {
      Map<String, dynamic> itemDetailsMap = itemDetails[i];

      List<String> categoryAndSubCategory = ['',''];
      if(itemDetailsMap['category'] != null) {
        categoryAndSubCategory = itemDetailsMap['category'].replaceAll(' ','').split('>');
      }

      List<Map<String, dynamic>> type_id = await DB.rawQuery('SELECT id FROM clothing_types WHERE type_name="${categoryAndSubCategory[0]}"'); //[{id: 2}]
      print(type_id);
      if (type_id.isEmpty) {
        type_id = [{'id': -1}];
      }

      List<Map<String, dynamic>> subtype_id = await DB.rawQuery(
          'SELECT id FROM clothing_sub_types WHERE sub_type_name="${categoryAndSubCategory[1]}"');
      if (subtype_id.isEmpty) {
        subtype_id = [{'id': -1}];
      }

      String image_path = widget.images[i].path;
      String image_url = ''; // TODO figure out if i need this. Was going to use for Firebase
      String tags = itemDetailsMap['tags'] ?? '';
      int is_archived = 0;
      String materials = itemDetailsMap['material'] ?? '';
      String colors = itemDetailsMap['color'] ?? '';
      int creation_datetime = DateTime.timestamp().millisecondsSinceEpoch;
      String patterns = itemDetailsMap['pattern'] ?? '';
      String brand = itemDetailsMap['brand'] ?? '';
      String purchase_date = itemDetailsMap['date'] ?? '';
      double price = itemDetailsMap['price'] == null ? 0.00:double.parse(itemDetailsMap['price']);
      String shop_link = itemDetailsMap['url'] ?? '';
      int is_spring = itemDetailsMap['season'] == null ? 0:itemDetailsMap['season'].contains('Spring') ? 1:0;
      int is_summer = itemDetailsMap['season'] == null ? 0:itemDetailsMap['season'].contains('Summer') ? 1:0;
      int is_fall = itemDetailsMap['season'] == null ? 0:itemDetailsMap['season'].contains('Fall') ? 1:0;
      int is_winter = itemDetailsMap['season'] == null ? 0:itemDetailsMap['season'].contains('Winter') ? 1:0;
      int is_available = itemDetailsMap['isAvailable'] == null ? 1:0;
      String size = itemDetailsMap['size'] ?? '';
      String note = itemDetailsMap['notes'] ?? '';

      ClothingItem clothingItem = ClothingItem(
        type_id: type_id[0]['id'],
        subtype_id: subtype_id[0]['id'],
        image_path: image_path,
        image_url: image_url,
        tags: tags,
        is_archived: is_archived,
        materials: materials,
        colors: colors,
        creation_datetime: creation_datetime,
        patterns: patterns,
        brand: brand,
        purchase_date: purchase_date,
        price: price,
        shop_link: shop_link,
        is_spring: is_spring,
        is_summer: is_summer,
        is_fall: is_fall,
        is_winter: is_winter,
        is_available: is_available,
        size: size,
        note: note,
      );
      await DB.insert('clothing_item', clothingItem);
      print('Item added to clothing_item table');
      // Wardrobe wardrobeItem = Wardrobe(
      //
      // );
      // await DB.insert('wardrobe', wardrobeItem);
     }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // print('dispose tag controller');

    _pageController.removeListener(onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Future<bool> isExitDesired() async {
      return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Are you sure?'),
                  content:
                      const Text('If you exit now your progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Leave'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Stay'),
                    ),
                  ],
                );
              }) ??
          false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              // boxShadow: [
              //   BoxShadow(blurRadius: 5, color: Colors.grey.shade800)
              // ],
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: const Center(
          child: Text(
            'Clothing Details',
            style: TextStyle(fontSize: 25.0),
          ),
        ),
        elevation: 0.0,
        actions: const [],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SizedBox(
              height: height * 3,
              width: width * 3,
              child: WillPopScope(
                onWillPop: isExitDesired,
                child: PageView(
                  pageSnapping: true,
                  // physics: const CustomPhysics(),
                  controller: _pageController,
                  // onPageChanged: (pageIdx) => _pageController.animateToPage(
                  //   pageIdx,
                  //   duration: const Duration(milliseconds: 100),
                  //   curve: Curves.linearToEaseOut,
                  // ),
                  children: [
                    for (int i = 0; i < widget.images.length; i++)
                      //           Expanded(
                      //       child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      // child: Scrollbar(
                      //   thumbVisibility: true,
                      //   thickness: 5, //width of scrollbar
                      //   radius: const Radius.circular(
                      //       20), //corner radius of scrollbar
                      //   scrollbarOrientation:
                      //   ScrollbarOrientation.right,
                      //   child: SingleChildScrollView(
                      //     controller: _firstController,
                      //     child: Padding(
                      //       padding:
                      //       EdgeInsets.fromLTRB(10, 10, 10, 20),
                      //       child: Container(
                      Scrollbar(
                        thickness: 5,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        radius: const Radius.circular(20),
                        child: SingleChildScrollView(
                          controller: _firstController,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 20.0, 10.0, 10.0),
                                  child: SizedBox(
                                    width: width * .6,
                                    child: Stack(
                                      children: [
                                        FullScreenWidget(
                                          disposeLevel: DisposeLevel.Low,
                                          child: Hero(
                                            tag:
                                                'image-${basenameWithoutExtension(widget.images[i].path)}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: AnimatedBuilder(
                                                animation: _scrollController,
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  if (_scrollController
                                                      .hasClients) {
                                                    double cHeight =
                                                        _scrollController
                                                                .offset *
                                                            screenHeight /
                                                            (itemHeight *
                                                                itemsCount);
                                                  }
                                                  // TODO: https://medium.com/flutter-community/scrolling-animation-in-flutter-6a6718b8e34f
                                                  // Treat image as the scrolling animation and the number of widgets in the form as the listview
                                                  return Image.file(
                                                    File(widget.images[i].path),
                                                    frameBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        int? frame,
                                                        bool
                                                            wasSynchronouslyLoaded) {
                                                      if (wasSynchronouslyLoaded) {
                                                        return child;
                                                      }
                                                      return AnimatedOpacity(
                                                        opacity: frame == null
                                                            ? 0
                                                            : 1,
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                        curve: Curves.easeIn,
                                                        child: child,
                                                      );
                                                    },
                                                    fit: BoxFit.fill,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0.0, 0.0, 0.0, 10.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          // TODO: https://flutterawesome.com/a-scrollable-dismissable-by-swiping-zoomable-rotatable-image-gallery-for-flutter/
                                                          PhotoEditScreen(
                                                              widget.images[i]),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: const CircleBorder(),
                                                ),
                                                child: const Icon(Icons.edit),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10.0, 0.0, 0.0, 10.0),
                                              child: Text(
                                                ' ${i + 1}/${widget.images.length} ',
                                                style: const TextStyle(
                                                    backgroundColor:
                                                        Colors.white70,
                                                    letterSpacing: 2.0,
                                                    fontSize: 18.0),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.grey,
                                  //     border: Border.all(
                                  //       color: Colors.red,
                                  //     ),
                                  //     borderRadius: const BorderRadius.all(
                                  //       Radius.circular(20),
                                  //     ),
                                  //   ),
                                  //   child: Text(
                                  //     'Clothing Details',
                                  //     style: TextStyle(fontSize: 25.0),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                                child: Container(
                                  child: ClothingInfoForm(
                                    itemDetailsMap: itemDetails[i],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   color: Colors.red,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       // Expanded(child: Container()),
          //       // Previous and Next buttons
          //       Padding(
          //         padding: const EdgeInsets.all(0.0),
          //         child: GestureDetector(
          //           onHorizontalDragUpdate: (details) {
          //             if (details.primaryDelta! > 0) {
          //               _pageController.animateToPage(
          //                   _pageController.page!.toInt() + 1,
          //                   duration: const Duration(milliseconds: 5),
          //                   curve: Curves.easeIn);
          //               // _pageController.jumpToPage(
          //               //     (_pageController.page!.toInt() + 1)
          //               //         .clamp(0, widget.images.length));
          //             }
          //             if (details.primaryDelta! < 0) {
          //               _pageController.animateToPage(
          //                   _pageController.page!.toInt() - 1,
          //                   duration: const Duration(milliseconds: 5),
          //                   curve: Curves.easeIn);
          //               // _pageController.jumpToPage(
          //               //     (_pageController.page!.toInt() - 1)
          //               //         .clamp(0, widget.images.length));
          //             }
          //           },
          //           child: SmoothPageIndicator(
          //             controller: _pageController,
          //             count: widget.images.length,
          //             effect: ScrollingDotsEffect(
          //               maxVisibleDots: 5,
          //               activeDotColor: Colors.grey.shade600,
          //               activeDotScale: 1.5,
          //               dotColor: Colors.grey,
          //               dotHeight: 10,
          //               dotWidth: 10,
          //               spacing: 10,
          //               fixedCenter: false,
          //             ),
          //             onDotClicked: (page) {
          //               HapticFeedback.selectionClick();
          //               _pageController.animateToPage(page,
          //                   duration: const Duration(milliseconds: 500),
          //                   curve: Curves.easeIn);
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          widget.images.length == 1
              ? Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.vibrate();
                            // Get all of the item details
                            // saveData(itemDetails);
                            print(itemDetails);
                            saveClotingItem();
                            // TODO add to wardrobe
                          },
                          child: const Text('Save Item'),
                        ),
                      ),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      if (currentPage > 0 &&
                          currentPage != widget.images.length - 1) ...[
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                _pageController.animateToPage(
                                    _pageController.page!.toInt() - 1,
                                    duration: const Duration(milliseconds: 50),
                                    curve: Curves.easeIn);
                              },
                              child: const Text('Previous'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                _pageController.animateToPage(
                                    _pageController.page!.toInt() + 1,
                                    duration: const Duration(milliseconds: 50),
                                    curve: Curves.easeIn);
                              },
                              child: const Text('Next'),
                            ),
                          ),
                        )
                      ] else if (currentPage == 0) ...[
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                // HapticFeedback.heavyImpact();
                                _pageController.animateToPage(
                                    _pageController.page!.toInt() + 1,
                                    duration: const Duration(milliseconds: 50),
                                    curve: Curves.easeIn);
                              },
                              child: const Text('Next'),
                            ),
                          ),
                        )
                      ] else ...[
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                _pageController.animateToPage(
                                    _pageController.page!.toInt() - 1,
                                    duration: const Duration(milliseconds: 50),
                                    curve: Curves.easeIn);
                              },
                              child: const Text('Previous'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                enableFeedback: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.vibrate();
                                print(itemDetails);
                                // for(int i=0; i<=itemDetails.length; i++) {
                                //   items.add(itemDetails[i])
                                // }
                                saveClotingItem();
                              },
                              child: const Text('Save All'),
                            ),
                          ),
                        )
                      ]
                    ]

                  // ],
                  )
        ],
      ),
    );
  }
}

class HeroWidgetImage extends StatefulWidget {
  final String imagePath;

  const HeroWidgetImage({super.key, required this.imagePath});

  @override
  State<HeroWidgetImage> createState() => _HeroWidgetImageState();
}

class _HeroWidgetImageState extends State<HeroWidgetImage> {
  @override
  Widget build(BuildContext context) {
    return FullScreenWidget(
      disposeLevel: DisposeLevel.High,
      child: Hero(
        tag: 'image-${basenameWithoutExtension(widget.imagePath)}',
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FullScreenWidget extends StatelessWidget {
  const FullScreenWidget(
      {super.key, required this.child,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      required this.disposeLevel});

  final Widget child;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final DisposeLevel disposeLevel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        Navigator.push(
            context,
            PageRouteBuilder(
                opaque: false,
                barrierColor: backgroundIsTransparent
                    ? Colors.white.withOpacity(0)
                    : backgroundColor,
                pageBuilder: (BuildContext context, _, __) {
                  return FullScreenPage(
                    backgroundColor: backgroundColor,
                    backgroundIsTransparent: backgroundIsTransparent,
                    disposeLevel: disposeLevel,
                    child: child,
                  );
                }));
      },
      child: child,
    );
  }
}

enum DisposeLevel { High, Medium, Low }

class FullScreenPage extends StatefulWidget {
  const FullScreenPage(
      {super.key, required this.child,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.disposeLevel = DisposeLevel.Medium});

  final Widget child;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final DisposeLevel disposeLevel;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  double initialPositionY = 0;

  double currentPositionY = 0;

  double positionYDelta = 0;

  double opacity = 1;

  double disposeLimit = 150;

  late Duration animationDuration;

  @override
  void initState() {
    super.initState();
    setDisposeLevel();
    animationDuration = Duration.zero;
  }

  setDisposeLevel() {
    setState(() {
      if (widget.disposeLevel == DisposeLevel.High) {
        disposeLimit = 300;
      } else if (widget.disposeLevel == DisposeLevel.Medium)
        disposeLimit = 200;
      else
        disposeLimit = 100;
    });
  }

  void _startVerticalDrag(details) {
    setState(() {
      initialPositionY = details.globalPosition.dy;
    });
  }

  void _whileVerticalDrag(details) {
    setState(() {
      currentPositionY = details.globalPosition.dy;
      positionYDelta = currentPositionY - initialPositionY;
      setOpacity();
    });
  }

  setOpacity() {
    double tmp = positionYDelta < 0
        ? 1 - ((positionYDelta / 1000) * -1)
        : 1 - (positionYDelta / 1000);

    if (tmp > 1) {
      opacity = 1;
    } else if (tmp < 0)
      opacity = 0;
    else
      opacity = tmp;

    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      opacity = 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    endVerticalDrag(DragEndDetails details) {
      if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          animationDuration = const Duration(milliseconds: 300);
          opacity = 1;
          positionYDelta = 0;
        });

        Future.delayed(animationDuration).then((_) {
          setState(() {
            animationDuration = Duration.zero;
          });
        });
      }
    }

    return Scaffold(
      backgroundColor: widget.backgroundIsTransparent
          ? Colors.transparent
          : widget.backgroundColor,
      body: GestureDetector(
        onVerticalDragStart: (details) => _startVerticalDrag(details),
        onVerticalDragUpdate: (details) => _whileVerticalDrag(details),
        onVerticalDragEnd: (details) => endVerticalDrag(details),
        child: Container(
          color: widget.backgroundColor.withOpacity(opacity),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: animationDuration,
                curve: Curves.fastOutSlowIn,
                top: 0 + positionYDelta,
                bottom: 0 - positionYDelta,
                left: 0,
                right: 0,
                child: widget.child,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomPhysics extends ScrollPhysics {
  const CustomPhysics({super.parent});

  @override
  CustomPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1000,
        stiffness: 1000,
        damping: .1,
      );
}
