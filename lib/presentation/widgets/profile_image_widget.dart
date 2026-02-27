import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget{
  final String? imageUrl;
  final double outerBorderRadius;
  final double innerBorderRadius;
  final bool isLocalFile;
  const ProfileImageWidget({super.key, required this.imageUrl, this.outerBorderRadius = 65, this.innerBorderRadius = 60, this.isLocalFile = false});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: outerBorderRadius,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: innerBorderRadius,
        backgroundImage: isLocalFile
            ? FileImage(File(imageUrl!)) : imageUrl != null ? CachedNetworkImageProvider(imageUrl!) : null,
      ),
    );
  }
}