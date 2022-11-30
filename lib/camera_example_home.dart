import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_plugin_app/widgets/camera_lens_icon.dart';
import 'package:flutter/material.dart';

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
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                _cameraTogglesRowWidget(),
                _thumbnailWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(
        controller!,
        child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
          );
        }),
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageFile == null)
              Container()
            else
              SizedBox(width: 64.0, height: 64.0, child: Image.file(File(imageFile!.path)))
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return IconButton(
      icon: const Icon(Icons.camera_alt),
      color: Colors.blue,
      onPressed: cameraController != null && cameraController.value.isInitialized
          ? onTakePictureButtonPressed
          : null,
    );
  }

  Widget _cameraTogglesRowWidget() {
    final List<Widget> toggles = [];

    void onChanged(CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    }

    if (widget.cameras.isEmpty) {
      print("Cameras empty");
      return const Text('None');
    } else {
      for (final CameraDescription cameraDescription in widget.cameras) {
        toggles.add(
          SizedBox(
            width: 90.0,
            child: RadioListTile<CameraDescription>(
              title: Icon(cameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: onChanged,
            ),
          ),
        );
      }
    }

    return Row(children: toggles);
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
      ResolutionPreset.medium,
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

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        if (file != null) {
          print('🎃🎃🎃🎃🎃🎃🎃 Picture saved to ${file.path}');
        }
      }
    });
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }
}
