// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:camera_plugin_app/presentation/widgets/camera_lens_icon.dart';
import 'package:flutter/material.dart';

Widget cameraTogglesRowWidget(
  CameraController? controller,
  List<CameraDescription> cameras,
  Future<void> Function(CameraDescription cameraDescription) onNewCameraSelected,
) {
  final List<Widget> toggles = [];

  void onChanged(CameraDescription? description) {
    print(description);
    if (description == null) {
      return;
    }

    onNewCameraSelected(description);
  }

  if (cameras.isEmpty) {
    print("Cameras empty");
    return const Text('None');
  } else {
    for (final CameraDescription cameraDescription in cameras) {
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
