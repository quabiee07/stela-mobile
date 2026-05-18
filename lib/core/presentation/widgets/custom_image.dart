import 'dart:io';

import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  const CustomImage(
      {super.key,
      required this.asset,
      this.height,
      this.color,
      this.width,
      this.isFile = false,
      this.file,
      this.fit = BoxFit.contain});
  final String asset;
  final double? height;

  final Color? color;
  final double? width;

  final BoxFit fit;
  final bool? isFile;
  final File? file;

  @override
  Widget build(BuildContext context) {
    return isFile == true
        ? Image.file(
            file!,
            height: height,
            width: width,
            fit: fit,
          )
        : Image.asset(
            asset,
            height: height,
            width: width,
            fit: fit,
          );
  }
}
