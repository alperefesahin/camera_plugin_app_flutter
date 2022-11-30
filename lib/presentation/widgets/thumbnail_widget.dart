import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Display the thumbnail of the captured image or video.
Widget thumbnailWidget(XFile? imageFile) {
  return Expanded(
    child: Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageFile == null)
            Container()
          else
            SizedBox(width: 64.0, height: 64.0, child: Image.file(File(imageFile.path)))
        ],
      ),
    ),
  );
}
