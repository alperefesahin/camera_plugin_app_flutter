import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Display the preview from the camera (or a message if the preview is not available).
Widget cameraPreviewWidget(CameraController? controller) {
  if (controller == null || !controller.value.isInitialized) {
    return const Text(
      'Tap a camera',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
      ),
    );
  } else {
    return CameraPreview(controller);
  }
}
