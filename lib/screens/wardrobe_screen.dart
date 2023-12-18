// TODO https://pub.dev/packages/carousel_slider/example
// TODO https://blog.logrocket.com/creating-image-carousel-flutter/
// TODO https://pub.dev/packages/shimmer

import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../theme/theme_manager.dart';

// TODO https://medium.com/geekculture/image-classification-with-flutter-182368fea3b
// TODO https://pub.dev/packages/photo_view

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key, required this.user});
  final User? user;
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final bool _pinned = true;
  final bool _snap = false;
  final bool _floating = false;
  late CameraDescription? firstCamera;
  List<CameraDescription> cameras = [];
  List<String> urls = [];
  String title = 'Wardrobe';
  late Future<ListResult> wardrobeData = Future<ListResult>.delayed(
    const Duration(seconds: 0),
    () async {
      Future<List<String>> imageList;
      // return await DB
      //     .rawQuery('SELECT id, type_id, subtype_id, tags FROM wardrobe');
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${widget.user!.uid}/images/');
      final listResult = await storageRef.listAll();
      for (var item in listResult.items) {
        String url = await getDownloadUrl(item);
        print('hello');
        urls.add(url);
      }
      return listResult;
    },
  );

  Future<String> getDownloadUrl(var item) async {
    print('wtf');
    var storageRef = FirebaseStorage.instance.ref();
    final imageUrl = await storageRef
        .child('users/${widget.user!.uid}/images/${item.name}')
        .getDownloadURL();
    // .toString();
    return Future.value(imageUrl);
  }

  @override
  void initState() {
    getCamera();
    getWardrobeData();
    super.initState();
  }

  // void _buildWardrobe() async {
  //   wardrobeData = await DB
  //       .rawQuery('SELECT type_id, subtype_id, image, tags FROM wardrobe');
  // }

  void getCamera() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    firstCamera = cameras.first;
    this.cameras = cameras;
  }

  void getWardrobeData() async {
    // TODO Store url in sqlite after uploading the photo to firebase
    // TODO Store the file path in sqlite
    // retrieve the image by url from sqlite to use to download the image to show
  }

  @override
  Widget build(BuildContext context) {
    // Return a blank add screen if there are no clothing items to show
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          backgroundColor: Provider.of<ThemeManager>(context).isDark
              ? Colors.black
              : Colors.white,
          body: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: FutureBuilder(
                future: wardrobeData,
                builder:
                    (BuildContext context, AsyncSnapshot<ListResult> snapshot) {
                  List<Widget> children;
                  List<Widget> items = [];
                  if (snapshot.hasData && snapshot.data!.items.isEmpty) {
                    // wardrobeData.whenComplete(() {
                    print('Wardrobe data done');
                    for (var item in snapshot.data!.items) {
                      print(item.fullPath);
                    }
                    children = <Widget>[
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('0 ITEMS'),
                          Text('Your Closet'),
                        ],
                      ),
                      Column(
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              'assets/images/wardrobe_empty.svg',
                              semanticsLabel: 'An empty wardrobe',
                              width: 225,
                              height: 225,
                            ),
                          )
                        ],
                      )
                    ];
                  } else if (snapshot.hasData &&
                      snapshot.data!.items.isNotEmpty) {
                    // print(snapshot.data);
                    for (String url in urls) {
                      print(url);
                      items.add(Container(
                        margin: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          child: Stack(
                            children: [
                              Image.network(url,
                                  fit: BoxFit.cover, width: 1000),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(200, 0, 0, 0),
                                        Color.fromARGB(0, 0, 0, 0)
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Text(
                                    'No. ${items.length + 1} image',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    }
                    children = <Widget>[
                      Row(
                        children: [
                          CarouselSlider(
                            items: items,
                            options: CarouselOptions(
                              autoPlay: false,
                              aspectRatio: 2.0,
                              enlargeCenterPage: true,
                              // height: MediaQuery.of(context).size.height,
                              // enlargeStrategy: CenterPageEnlargeStrategy.scale,
                              viewportFraction: 0.84,
                            ),
                            // carouselController: ,
                          ),
                        ],
                      ),
                    ];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: children,
                    );
                    // });
                  } else if (snapshot.hasData == false) {
                    print('no data detected');
                    children = <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ];
                  } else {
                    children = const <Widget>[
                      Text('Error: there is null data')
                    ];
                  }

                  return Column(
                    // mainAxisAlignment: mainAxisAlignment,
                    // crossAxisAlignment: crossAxisAlignment,
                    children: children,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Route _createRoute(List<CameraDescription> cameras,
//     CameraDescription firstCamera, String uid) {
//   print(firstCamera);
//   print(cameras);
//   // CameraDescription cameraDescription, List<CameraDescription> cameras) {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         CameraScreen(uid: uid),
//     // pageBuilder: (context, animation, secondaryAnimation) => NewItemFlow(
//     //   addItemPageRoute: '/wardrobe/add/camera',
//     //   camera: firstCamera,
//     //   cameraList: cameras,
//     // ),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(1.0, 0.0);
//       const end = Offset.zero;
//       const curve = Curves.ease;
//
//       var tween = Tween(
//         begin: begin,
//         end: end,
//       ).chain(CurveTween(
//         curve: curve,
//       ));
//
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
