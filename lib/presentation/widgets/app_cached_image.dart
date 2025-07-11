import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/cache_manager.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      'assets/icons/app_icon.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _wrap(placeholder);
    }

    final img = CachedNetworkImage(
      imageUrl: imageUrl!,
      cacheManager: AppCacheManagers.imageCache,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );

    return _wrap(img);
  }

  Widget _wrap(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
