// TODO: Update the camera UI
// TODO: Add swipe away animation to close preview
// TODO: Fix camera flash bug
// https://github.com/flutter/plugins/blob/main/packages/camera/camera/example/lib/main.dart
// https://blog.logrocket.com/flutter-camera-plugin-deep-dive-with-examples/#zoom-control
// https://github.com/sbis04/flutter_camera_demo/blob/main/lib/screens/camera_screen.dart
//https://stackoverflow.com/questions/57071817/flutter-how-correctly-pause-camera-when-user-moved-to-other-preview-screen
//https://medium.com/swlh/uploading-images-to-cloud-storage-using-flutter-130ac41741b2

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_lookbook/screens/photo_preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget with WidgetsBindingObserver {
  const CameraScreen({super.key, required this.user});
  final User? user;
  // final CameraDescription camera;
  // final List<CameraDescription>? cameraList;
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  // VideoPlayerController? videoController;

  late CameraDescription? firstCamera;
  List<CameraDescription> cameras = [];

  File? _imageFile;
  File? _videoFile;

  Color cameraButtonColor = Colors.white;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  final bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  final double _baseZoomLevel = 0;
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;

  void getCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    print('Cameras Found: $cameras');
  }

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(firstCamera!);
      refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    for (var file in fileList) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    }

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        // _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    // Hide the status bar in Android
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    getCamera();
    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    // videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    // final xScale = controller!.value.aspectRatio / deviceRatio;
// Modify the yScale if you are in Landscape
//     final yScale = 1;

    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: deviceRatio,
                          child: Stack(
                            children: [
                              // https://stackoverflow.com/questions/56735552/how-to-set-flutter-camerapreview-size-fullscreen
                              Transform.scale(
                                scale: 1 /
                                    (controller!.value.aspectRatio *
                                        MediaQuery.of(context)
                                            .size
                                            .aspectRatio),
                                alignment: Alignment.topCenter,
                                child: CameraPreview(
                                  controller!,
                                  child: LayoutBuilder(builder:
                                      (BuildContext context,
                                          BoxConstraints constraints) {
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) =>
                                          onViewFinderTap(details, constraints),
                                      // onScaleUpdate:
                                      //     (scaleUpdateDetails) async {
                                      //   var maxZoomLevel =
                                      //       await controller?.getMaxZoomLevel();
                                      //   setState(() {
                                      //     var dragIntensity =
                                      //         scaleUpdateDetails.scale;
                                      //     if (dragIntensity < 1) {
                                      //       // 1 is the minimum zoom level required by the camController's method, hence setting 1 if the user zooms out (less than one is given to details when you zoom-out/pinch-in).
                                      //       // _currentZoomLevel = dragIntensity;
                                      //       controller?.setZoomLevel(1);
                                      //     } else if (dragIntensity > 1 &&
                                      //         dragIntensity < maxZoomLevel!) {
                                      //       // self-explanatory, that if the maxZoomLevel exceeds, you will get an error (greater than one is given to details when you zoom-in/pinch-out).
                                      //       // _currentZoomLevel = dragIntensity;
                                      //       controller
                                      //           ?.setZoomLevel(dragIntensity);
                                      //     } else {
                                      //       // if it does exceed, you can provide the maxZoomLevel instead of dragIntensity (this block is executed whenever you zoom-in/pinch-out more than the max zoom level).
                                      //       // _currentZoomLevel = dragIntensity;
                                      //       controller
                                      //           ?.setZoomLevel(maxZoomLevel!);
                                      //     }
                                      //   });
                                      //   await controller!
                                      //       .setZoomLevel(_currentZoomLevel);
                                      // },
                                    );
                                  }),
                                ),
                              ),
                              // TODO: Uncomment to preview the overlay
                              // Center(
                              //   child: Image.asset(
                              //     'assets/camera_aim.png',
                              //     color: Colors.greenAccent,
                              //     width: 150,
                              //     height: 150,
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  8.0,
                                  16.0,
                                  8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 8.0, 16.0, 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      _currentFlashMode =
                                                          FlashMode.off;
                                                    });
                                                    await controller!
                                                        .setFlashMode(
                                                      FlashMode.off,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.flash_off,
                                                    color: _currentFlashMode ==
                                                            FlashMode.off
                                                        ? Colors.amber
                                                        : Colors.white,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      _currentFlashMode =
                                                          FlashMode.auto;
                                                    });
                                                    await controller!
                                                        .setFlashMode(
                                                      FlashMode.auto,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.flash_auto,
                                                    color: _currentFlashMode ==
                                                            FlashMode.auto
                                                        ? Colors.amber
                                                        : Colors.white,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      _currentFlashMode =
                                                          FlashMode.always;
                                                    });
                                                    await controller!
                                                        .setFlashMode(
                                                      FlashMode.always,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.flash_on,
                                                    color: _currentFlashMode ==
                                                            FlashMode.always
                                                        ? Colors.amber
                                                        : Colors.white,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      _currentFlashMode =
                                                          FlashMode.torch;
                                                    });
                                                    await controller!
                                                        .setFlashMode(
                                                      FlashMode.torch,
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.highlight,
                                                    color: _currentFlashMode ==
                                                            FlashMode.torch
                                                        ? Colors.amber
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0, top: 16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${_currentExposureOffset
                                                    .toStringAsFixed(1)}x',
                                            style:
                                                const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: SizedBox(
                                          height: 30,
                                          child: Slider(
                                            value: _currentExposureOffset,
                                            min: _minAvailableExposureOffset,
                                            max: _maxAvailableExposureOffset,
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white30,
                                            onChanged: (value) async {
                                              setState(() {
                                                _currentExposureOffset = value;
                                              });
                                              await controller!
                                                  .setExposureOffset(value);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Slider(
                                            value: _currentZoomLevel,
                                            min: _minAvailableZoom,
                                            max: _maxAvailableZoom,
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white30,
                                            onChanged: (value) async {
                                              setState(() {
                                                _currentZoomLevel = value;
                                              });
                                              await controller!
                                                  .setZoomLevel(value);
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '${_currentZoomLevel
                                                        .toStringAsFixed(1)}x',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: _isRecordingInProgress
                                              ? () async {
                                                  if (controller!.value
                                                      .isRecordingPaused) {
                                                    await resumeVideoRecording();
                                                  } else {
                                                    await pauseVideoRecording();
                                                  }
                                                }
                                              : () {
                                                  setState(() {
                                                    _isCameraInitialized =
                                                        false;
                                                  });
                                                  onNewCameraSelected(cameras[
                                                      _isRearCameraSelected
                                                          ? 1
                                                          : 0]);
                                                  setState(() {
                                                    _isRearCameraSelected =
                                                        !_isRearCameraSelected;
                                                  });
                                                },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(
                                                Icons.circle,
                                                color: Colors.black38,
                                                size: 60,
                                              ),
                                              _isRecordingInProgress
                                                  ? controller!.value
                                                          .isRecordingPaused
                                                      ? const Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.white,
                                                          size: 30,
                                                        )
                                                      : const Icon(
                                                          Icons.pause,
                                                          color: Colors.white,
                                                          size: 30,
                                                        )
                                                  : Icon(
                                                      _isRearCameraSelected
                                                          ? Icons.camera_front
                                                          : Icons.camera_rear,
                                                      color: Colors.white,
                                                      size: 30,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onForcePressEnd: (d) {
                                            setState(() {
                                              cameraButtonColor = Colors.white;
                                            });
                                          },
                                          onLongPress: () {
                                            setState(() {
                                              cameraButtonColor =
                                                  Colors.grey[350]!;
                                            });
                                          },
                                          onLongPressStart: (details) {
                                            setState(() {
                                              cameraButtonColor =
                                                  Colors.grey[350]!;
                                            });
                                          },
                                          onLongPressDown: (details) {
                                            setState(() {
                                              cameraButtonColor =
                                                  Colors.grey[350]!;
                                            });
                                          },
                                          onLongPressCancel: () {
                                            setState(() {
                                              cameraButtonColor = Colors.white;
                                            });
                                          },
                                          onLongPressEnd: (details) {
                                            setState(() {
                                              cameraButtonColor = Colors.white;
                                            });
                                          },
                                          onLongPressUp: () {
                                            setState(() {
                                              cameraButtonColor = Colors.white;
                                            });
                                          },
                                          child: InkWell(
                                            onTap: () async {
                                              print('pressed photo button');
                                              XFile? rawImage =
                                                  await takePicture();
                                              File imageFile =
                                                  File(rawImage!.path);

                                              int currentUnix = DateTime.now()
                                                  .millisecondsSinceEpoch;

                                              final directory =
                                                  await getApplicationDocumentsDirectory();

                                              String fileFormat = imageFile.path
                                                  .split('.')
                                                  .last;

                                              print(fileFormat);

                                              await imageFile.copy(
                                                '${directory.path}/$currentUnix.$fileFormat',
                                              );

                                              refreshAlreadyCapturedImages();
                                            },
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            200),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Icon(
                                                    Icons.circle,
                                                    color:
                                                        _isVideoCameraSelected
                                                            ? Colors.white
                                                            : Colors.white,
                                                    size: 0,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.circle,
                                                  color: _isVideoCameraSelected
                                                      ? Colors.white
                                                      : cameraButtonColor,
                                                  size: 105,
                                                ),
                                                // Icon(
                                                //   Icons.circle,
                                                //   color: _isVideoCameraSelected
                                                //       ? Colors.red
                                                //       : Colors.white,
                                                //   size: 65,
                                                // ),

                                                // _isVideoCameraSelected &&
                                                //         _isRecordingInProgress
                                                //     ? Icon(
                                                //         Icons.stop_rounded,
                                                //         color: Colors.white,
                                                //         size: 32,
                                                //       )
                                                //     : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _imageFile != null ||
                                                  _videoFile != null
                                              ? () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PicturePreviewScreen(
                                                        onDeviceSelected: null,
                                                        cameraController:
                                                            controller,
                                                        user: widget.user,
                                                        imagePath:
                                                            _imageFile!.path,
                                                        // imageFile: _imageFile!,
                                                        // fileList: allFileList,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              image: _imageFile != null
                                                  ? DecorationImage(
                                                      image: FileImage(
                                                          _imageFile!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: Container(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Row(),
                  const Text(
                    'Permission denied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Give permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
