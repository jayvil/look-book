import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:my_lookbook/constants.dart';
import 'package:my_lookbook/screens/camera_screen.dart';

import '../screens/photo_preview_screen.dart';

class NewItemFlow extends StatefulWidget {
  NewItemFlow({
    super.key,
    required this.addItemPageRoute,
    required this.camera,
    required this.cameraList,
  });

  final String addItemPageRoute;
  CameraDescription camera;
  List<CameraDescription> cameraList;
  @override
  State<NewItemFlow> createState() => _NewItemFlowState();
}

class _NewItemFlowState extends State<NewItemFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  // late CameraDescription? camera;
  // late List<CameraDescription> cameraList = [];

  @override
  void initState() {
    // getCamera();
    super.initState();
  }

  void getCamera() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    // WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    // final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    // firstCamera = cameras.first;
    // this.cameras = cameras;
  }

  // void _onDiscoveryComplete() {
  //   _navigatorKey.currentState!.pushNamed(routeWardrobeAddCamera);
  // }
  //
  // void _onDeviceSelected(String deviceId) {
  //   _navigatorKey.currentState!.pushNamed(routeDeviceSetupStartPage);
  // }
  //
  // void _onConnectionEstablished() {
  //   _navigatorKey.currentState!.pushNamed(routeDeviceSetupFinished);
  // }
  //
  // void _onCaptureComplete() {
  //   _navigatorKey.currentState!.pushNamed(kRouteVerifyCapture);
  // }
  //
  // void _onVerifyCaptureComplete() {
  //   _navigatorKey.currentState!.pushNamed(kRouteFinished);
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isExitDesired,
      child: Scaffold(
        appBar: _buildFlowAppBar(),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: widget.addItemPageRoute,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    String subRoute;
    if (settings.name!.startsWith(routePrefixWardrobeAdd)) {
      subRoute = settings.name!.substring(routePrefixWardrobeAdd.length);
      print(subRoute);

      switch (subRoute) {
        case routeWardrobeAddCamera:
          page = CameraScreen(
            camera: widget.camera,
            cameraList: widget.cameraList,
          );
          break;
        case routeDeviceSetupStartPage:
          page = const PicturePreviewScreen(
            cameraController: null,
            imagePath: '',
            onDeviceSelected: null,
          );
          break;
        // case routeDeviceSetupConnectingPage:
        //   page = WaitingPage(
        //     message: 'Connecting...',
        //     onWaitComplete: _onConnectionEstablished,
        //   );
        //   break;
        // case routeDeviceSetupFinishedPage:
        //   page = FinishedPage(
        //     onFinishPressed: _exitSetup,
        //   );
        //   break;
      }
    }
    return MaterialPageRoute<dynamic>(
      builder: (context) {
        print('THIS IS THE PAGE');
        print(page);
        return page;
      },
      settings: settings,
    );
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();

    if (isConfirmed && mounted) {
      _exitSetup();
    }
  }

  Future<bool> _isExitDesired() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text(
                    'If you exit device setup, your progress will be lost.'),
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

  void _exitSetup() {
    Navigator.of(context).pop();
  }

  PreferredSizeWidget _buildFlowAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: _onExitPressed,
        icon: const Icon(Icons.close_rounded),
      ),
      title: const Text('Add Wardrobe Item'),
    );
  }
}
