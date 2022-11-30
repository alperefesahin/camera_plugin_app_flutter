import 'package:camera/camera.dart';
import 'package:camera_plugin_app/camera_example_home.dart';
import 'package:flutter/material.dart';

class CameraApp extends StatelessWidget {
  const CameraApp({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraExampleHome(cameras: cameras),
    );
  }
}
