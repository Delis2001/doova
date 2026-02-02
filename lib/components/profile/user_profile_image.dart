import 'package:cached_network_image/cached_network_image.dart';
import 'package:doova/provider/profile/profile_image_provider.dart';
import 'package:doova/r.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class UserProfileImage extends StatelessWidget {
  const UserProfileImage({
    super.key,
    required this.buildProfileImageRadius,
    required this.fallbackWidgetRadius,
    required this.height,
    required this.placeholderWidgetRadius,
    required this.width,
  });

  final double buildProfileImageRadius;
  final double fallbackWidgetRadius;
  final double placeholderWidgetRadius;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageProviderNotifier>(
      builder: (context, imageProviderNotifier, child) {
        // Wait until data is initialized
        if (!imageProviderNotifier.isImageInitialized) {
          return  _placeholderWidget(context);
        }

        final imageUrl = imageProviderNotifier.networkImageUrl;
        final fallbackImage = imageProviderNotifier.fallbackImage;

        // Show fallback widget if both are still empty
        final isNewUser = (imageUrl == null || imageUrl.isEmpty) &&
            (fallbackImage == null || fallbackImage.isEmpty);
        if (isNewUser) return _fallbackWidget();

        // Use imageUrl if available, otherwise fallback
        final resolvedUrl = (imageUrl != null && imageUrl.isNotEmpty)
            ? imageUrl
            : fallbackImage!;

        return CircleAvatar(
          radius: buildProfileImageRadius,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: resolvedUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 200),
              placeholderFadeInDuration: Duration(milliseconds: 300),
              placeholder: (context, url) => _placeholderWidget(context),
              errorWidget: (context, url, error) {
                final canRetryFallback = imageUrl?.isNotEmpty == true &&
                    fallbackImage?.isNotEmpty == true &&
                    resolvedUrl != fallbackImage;

                if (canRetryFallback) {
                  return CachedNetworkImage(
                    imageUrl: fallbackImage!,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    placeholderFadeInDuration: Duration.zero,
                    placeholder: (context, url) => _placeholderWidget(context),
                    errorWidget: (context, url, error) => _fallbackWidget(),
                  );
                }

                return _fallbackWidget();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackWidget() {
    return CircleAvatar(
      radius: fallbackWidgetRadius,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(AssetsManager.circleAvatarImage),
    );
  }

  Widget _placeholderWidget(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
     final baseColor = isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xffE5E5E5);
      final highlightColor = isDarkMode ? const Color(0xFF3A3A3C) : const Color(0xffF0F0F0);
    return Shimmer.fromColors(
      baseColor:baseColor,
      highlightColor:highlightColor,
      child: CircleAvatar(
        radius: placeholderWidgetRadius,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      ),
    );
  }
}
