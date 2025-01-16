import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdaptiveImage extends StatelessWidget {
  final String imageSource;
  final BoxFit fit;
  final double? height; // New property for height
  final double? width; // New property for width

  const AdaptiveImage({
    Key? key,
    required this.imageSource,
    this.fit = BoxFit.cover,
    this.height, // Allow height to be optional
    this.width, // Allow width to be optional
  }) : super(key: key);

  bool isBase64String(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isValidUrl(String str) {
    return str.startsWith('http://') || str.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (isValidUrl(imageSource)) {
      return CachedNetworkImage(
        imageUrl: imageSource,
        fit: fit,
        height: height, // Set height if provided
        width: width, // Set width if provided
        placeholder: (context, url) => Transform.scale(
          scale: 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 1,
          ),
        ),
        errorWidget: (context, url, error) {
          print('Failed to load image: $url, error: $error');
          return const Icon(Icons.error);
        },
      );
    } else if (isBase64String(imageSource)) {
      try {
        return Image.memory(
          base64.decode(imageSource),
          fit: fit,
          height: height, // Set height if provided
          width: width, // Set width if provided
          errorBuilder: (context, error, stackTrace) {
            print('Failed to decode base64 image: $error');
            return const Icon(Icons.error);
          },
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return const Icon(Icons.error);
      }
    } else {
      return const Icon(Icons.broken_image);
    }
  }
}
