// A widget that displays the picture taken by the user.
// https://pub.dev/packages/image_crop
// https://www.youtube.com/watch?v=s9XHOQeIeZg

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_lookbook/db/db.dart';
import 'package:my_lookbook/db/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:path/path.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../theme/theme_manager.dart';
import 'navigation_screen.dart';

class PicturePreviewScreen extends StatefulWidget {
  final String imagePath;
  final CameraController? cameraController;
  final User? user;
  const PicturePreviewScreen(
      {super.key,
      required this.imagePath,
      required this.cameraController,
      required onDeviceSelected,
      required this.user});

  @override
  State<PicturePreviewScreen> createState() => _PicturePreviewScreenState();
}

class _PicturePreviewScreenState extends State<PicturePreviewScreen> {
  String? categoryDropdownValue;
  String? subCategoryDropdownValue;
  List<String> subCategoryDropDownList = [];
  List<String> dropDownList = [];
  late TextfieldTagsController _controller;
  late double _distanceToField;
  late PermissionStatus _permissionStatus;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    // Get permission to use local storage
    () async {
      _permissionStatus = await Permission.storage.status;
      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
        });
      }
    }();
    checkTable('clothing_types');
    getDropdownItems();
    populateSubCategories('Accessories');
    // populateSubCategories();
    _controller = TextfieldTagsController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  void checkTable(String tableName) async {
    List<Map<String, dynamic>> x = await DB.queryAll(tableName);
    print(x);
  }

  void getDropdownItems() async {
    // dropDownList.clear();
    List<Map<String, dynamic>> data = await DB.queryAll('clothing_types');
    for (Map<String, dynamic> mapData in data) {
      ClothingTypes clothingTypes = ClothingTypes.fromMap(mapData);
      dropDownList.add(clothingTypes.type_name);
      categoryDropdownValue = dropDownList.first;
    }
    dropDownList.sort();
    setState(() {});
    print('This is the dropdown list');
    print(dropDownList);
  }

  void populateSubCategories(String? category) async {
    // setState(() {
    // subCategoryDropDownList.clear();
    // subCategoryDropdownValue = "";
    // subCategoryDropDownList.add("");
    // });
    subCategoryDropDownList.clear();
    // categoryDropdownValue = value ?? "";
    // Get the id of the clothing type selection
    List<Map<String, dynamic>> clothingTypeData = await DB
        .rawQuery('SELECT id FROM clothing_types WHERE type_name="$category"');
    print(clothingTypeData);
    int resultId = clothingTypeData[0]['id'];
    print('THIS IS THE RESULT');
    print(resultId);
    List<Map<String, dynamic>> clothingSubTypeData = await DB.rawQuery(
        'SELECT sub_type_name FROM clothing_sub_types WHERE type_id=$resultId');
    print(clothingSubTypeData);
    for (Map<String, dynamic> item in clothingSubTypeData) {
      subCategoryDropDownList.add(item['sub_type_name']);
      subCategoryDropdownValue = subCategoryDropDownList.first;
    }
    subCategoryDropDownList.sort();
    setState(() {});
  }

  Future<String> uploadFile(File image) async {
    // final userContext = UserContext.of(context);
    // print(userContext);
    Reference storageReference = FirebaseStorage.instance.ref().child(
        'users/${widget.user!.uid}/images/${image.path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(image);
    await Future.value(uploadTask);
    print('File Uploaded');
    String returnURL = '';
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
      print(returnURL);
    });
    final metadata = await storageReference.getMetadata();
    print(metadata.fullPath);
    return Future.value(returnURL);
  }

  Future<String> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory())!
          .path; // OR return "/storage/emulated/0/Download";
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  createImage(var imageBytes) async {
    String dir = await getStorageDirectory();

    File directory = File(dir);
    if (await directory.exists() != true) {
      directory.create();
    }
    String filePath = '$directory/image.jpeg';
    File file = File(filePath);
    var newFile = await file.writeAsBytes(imageBytes);
    await newFile.create();
    print('Widget.imagePath = $widget.imagePath');
    print('File path = $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Provider.of<ThemeManager>(context).getTheme,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(
          //   leading: GestureDetector(
          //     child: const Icon(
          //       Icons.arrow_back_ios_new_sharp,
          //       size: 25.0,
          //     ),
          //     onTap: () {
          //       Navigator.pop(context);
          //     },
          //   ),
          //   backgroundColor: Colors.transparent,
          //   iconTheme: IconThemeData(
          //     color: Colors.white,
          //     size: 40.0,
          //   ),
          //   elevation: 0.0,
          //   title: const Text('Categorize Item'),
          //   centerTitle: true,
          // ),
          // The image is stored as a file on the device. Use the `Image.file`
          // constructor with the given path to display the image.
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    height: 500.0,
                  ),
                ),
              ),
              // SizedBox(
              //   height: 0.0,
              // ),
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          value: categoryDropdownValue,
                          enableFeedback: false,
                          hint: const Text("Choose a category"),
                          items: dropDownList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
                            // subCategoryDropDownList.clear();
                            // subCategoryDropdownValue = "";

                            setState(() {
                              populateSubCategories(value);
                              // if (subCategoryDropDownList.isNotEmpty) {
                              //   subCategoryDropdownValue = "";
                              //   subCategoryDropDownList.clear();
                              //   subCategoryDropDownList.add("");
                              // } else {}
                              categoryDropdownValue =
                                  value ?? dropDownList.first;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 6.0,
                        ),
                        DropdownButton<String>(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          value: subCategoryDropdownValue,
                          enableFeedback: false,
                          hint: const Text("Choose a sub category"),
                          items: subCategoryDropDownList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) async {
                            setState(() {
                              subCategoryDropdownValue =
                                  value ?? subCategoryDropDownList.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Expanded(
                      //   child: TextField(
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(),
                      //       hintText: 'Enter a search term',
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: TextFieldTags(
                            textfieldTagsController: _controller,
                            initialTags: const [],
                            textSeparators: const [' ', ','],
                            letterCase: LetterCase.normal,
                            validator: null,
                            inputfieldBuilder: (context, tec, fn, error,
                                onChanged, onSubmitted) {
                              return ((context, sc, tags, onTagDelete) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextField(
                                    controller: tec,
                                    focusNode: fn,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 74, 137, 92),
                                          width: 3.0,
                                        ),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 74, 137, 92),
                                          width: 3.0,
                                        ),
                                      ),
                                      helperText:
                                          'Enter tags to help describe this item',
                                      helperStyle: const TextStyle(
                                        color: Color.fromARGB(255, 74, 137, 92),
                                      ),
                                      hintText: _controller.hasTags
                                          ? ''
                                          : 'Enter tags to help describe this item',
                                      errorText: error,
                                      prefixIconConstraints: BoxConstraints(
                                          maxWidth: _distanceToField * 0.74),
                                      prefixIcon: tags.isNotEmpty
                                          ? SingleChildScrollView(
                                              controller: sc,
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                  children:
                                                      tags.map((String tag) {
                                                return Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20.0),
                                                    ),
                                                    color: Color.fromARGB(
                                                        255, 74, 137, 92),
                                                  ),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 5.0),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        child: Text(
                                                          tag,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        onTap: () {
                                                          print(
                                                              "$tag selected");
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      InkWell(
                                                        child: const Icon(
                                                          Icons.cancel,
                                                          size: 14.0,
                                                          color: Color.fromARGB(
                                                              255,
                                                              233,
                                                              233,
                                                              233),
                                                        ),
                                                        onTap: () {
                                                          onTagDelete(tag);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList()),
                                            )
                                          : null,
                                    ),
                                    onChanged: onChanged,
                                    onSubmitted: onSubmitted,
                                  ),
                                );
                              });
                            }),
                      )
                    ],
                  )
                ],
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      text: 'Retake',
                      function: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: MyButton(
                      text: 'Save and Finish',
                      function: () async {
                        print('The picture is good. Save it.');
                        String table = 'wardrobe';
                        Uint8List imageBytes =
                            await File(widget.imagePath).readAsBytes();
                        createImage(imageBytes);
                        List<Map<String, dynamic>> typeId = await DB.rawQuery(
                            'SELECT id FROM clothing_types WHERE type_name ="$categoryDropdownValue"');
                        List<
                            Map<String,
                                dynamic>> subTypeId = await DB.rawQuery(
                            'SELECT id FROM clothing_sub_types WHERE sub_type_name="$subCategoryDropdownValue"');
                        print('This is the image bytes $imageBytes');
                        print(jsonEncode(_controller.getTags));
                        print(typeId[0]['id']);
                        print(subTypeId[0]['id']);

                        // TODO RESERVE UPLOAD TO FIREBASE FOR PREMIUM?
                        /* var imageUrl = await uploadFile(File(widget.imagePath)); */

                        // Create Wardrobe item
                        // Wardrobe wardrobeItem = Wardrobe(
                        //     image_url: 'imageUrl',
                        //     image_path: widget.imagePath,
                        //     image: imageBytes,
                        //     tags: jsonEncode(_controller.getTags),
                        //     type_id: typeId[0]['id'],
                        //     subtype_id: subTypeId[0]['id']);
                        // print(wardrobeItem.toMap());
                        // await DB.insert(table, wardrobeItem);
                        // print('Item added to wardrobe table');

                        final http.Response response = await http.post(
                          Uri.parse('localhost:8080/wardrobe'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(
                              <String, String>{'imagepath': widget.imagePath}),
                        );
                        print(response.body);
                        // List<Map<String, dynamic>> data =
                        //     await DB.rawQuery('SELECT * FROM wardrobe');
                        // print(data);
                        // Navigator.popUntil(
                        //     context, ModalRoute.withName('/wardrobe'));

                        widget.cameraController?.dispose();
                        if (!mounted) return;
                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (BuildContext context) =>
                        //         HomeScreen(uid: widget.uid),
                        //   ),
                        //   (route) => false,
                        // );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                const NavigationScreen(
                              user: null,
                              activeIndex: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.function, required this.text});

  final VoidCallback function;
  final String text;
  @override
  Widget build(BuildContext context) {
    // The InkWell wraps the custom flat button widget.
    return InkWell(
      onTap: function,
      child: SizedBox(
        height: 35,
        child: Container(
          height: 100,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
