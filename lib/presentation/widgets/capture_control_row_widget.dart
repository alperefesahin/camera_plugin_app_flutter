import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Display the control bar with buttons to take pictures and record videos.
Widget captureControlRowWidget(
  CameraController? controller,
  void Function() onTakePictureButtonPressed,
) {
  return IconButton(
    icon: const Icon(Icons.camera_alt),
    color: Colors.blue,
    onPressed:
        controller != null && controller.value.isInitialized ? onTakePictureButtonPressed : null,
  );
}
