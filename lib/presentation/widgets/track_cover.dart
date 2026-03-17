import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Square album / track cover art with a rounded border.
/// Shows a music note placeholder when [url] is null.
class TrackCover extends StatelessWidget {
  const TrackCover({
    super.key,
    required this.url,
    required this.size,
    this.borderRadius = 8,
  });

  final String? url;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : _Placeholder(size: size),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.white12,
      child: const Icon(Icons.music_note, color: Colors.white38),
    );
  }
}
