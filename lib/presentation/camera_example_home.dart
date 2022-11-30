// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:camera_plugin_app/presentation/widgets/camera_preview_widget.dart';
import 'package:camera_plugin_app/presentation/widgets/camera_toggles_row_widget.dart';
import 'package:camera_plugin_app/presentation/widgets/capture_control_row_widget.dart';
import 'package:camera_plugin_app/presentation/widgets/thumbnail_widget.dart';
import 'package:flutter/material.dart';

// functions exist below, use your own state management solution and carry functions to there.
class CameraExampleHome extends StatefulWidget {
  const CameraExampleHome({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  State<CameraExampleHome> createState() {
    return _CameraExampleHomeState();
  }
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // #docregion AppLifecycle
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
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: Colors.grey,
                  width: 3.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: cameraPreviewWidget(controller),
                ),
              ),
            ),
          ),
          captureControlRowWidget(controller, onTakePictureButtonPressed),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                cameraTogglesRowWidget(controller, widget.cameras, onNewCameraSelected),
                thumbnailWidget(imageFile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          print('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          print('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          print('Camera access is restricted.');
          break;
        default:
          break;
      }
    }
  }

  Future onTakePictureButtonPressed() async {
    print("+++++1");
    final picture = await takePicture();
    print("PICTURE!!!!!: " + picture.toString());
    if (picture != null) {
      print('🎃🎃🎃🎃🎃🎃🎃 Picture saved to ${picture.path}');
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('!!!!!!!!!!!! Error: select a camera first.');
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print("CAMERA ERROR: " + e.toString());
      return null;
    }
  }
}
