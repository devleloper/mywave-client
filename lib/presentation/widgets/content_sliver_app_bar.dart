import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'bounceable.dart';

class ContentSliverAppBar extends StatelessWidget {
  const ContentSliverAppBar({
    super.key,
    required this.title,
    this.imageUrl,
    this.placeholderIcon = Icons.album,
  });

  final String title;
  final String? imageUrl;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Bounceable(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
            else
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(placeholderIcon, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            // Bottom gradient so the title remains legible.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
