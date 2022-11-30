import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

IconData cameraLensIcon(CameraLensDirection direction) {
  if (direction == CameraLensDirection.back) {
    return Icons.camera_rear;
  } else if (direction == CameraLensDirection.front) {
    return Icons.camera_front;
  }
  throw Exception("unknown direction error: $direction");
}
