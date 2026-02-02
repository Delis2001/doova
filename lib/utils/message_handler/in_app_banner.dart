import 'dart:async';
import 'package:flutter/material.dart';

class InAppBanner {
 static void show({
  required BuildContext context,
  required String title,
  required String body,
  VoidCallback? onTap,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _BannerWidget(
      title: title,
      body: body,
      onTap: () {
        entry.remove();
        onTap?.call();
      },
    ),
  );

  overlay.insert(entry);

  Timer(duration, () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}

}

class _BannerWidget extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;

  const _BannerWidget({
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications, color: Color(0xff6F24E9)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
