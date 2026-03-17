import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
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
                color: AppTheme.surface,
                child: Icon(placeholderIcon, size: 64, color: Colors.white38),
              ),
            // Bottom gradient so the title remains legible.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xE6121212), // AppTheme.background at 90 %
                    Color(0xFF121212), // AppTheme.background at 100 %
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
