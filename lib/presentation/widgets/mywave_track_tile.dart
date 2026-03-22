import 'package:flutter/material.dart';
import 'bounceable.dart';
import 'track_cover.dart';
import 'explicit_badge.dart';
import '../../domain/entities/track.dart';

class MyWaveTrackTile extends StatelessWidget {
  final Track track;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final String? subtitle;

  const MyWaveTrackTile({
    super.key,
    required this.track,
    this.index,
    required this.onTap,
    this.onMoreTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Bounceable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            if (index != null) ...[
              SizedBox(
                width: 32,
                child: Text(
                  '${index! + 1}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (track.album?.coverUrl != null) ...[
              TrackCover(url: track.album!.coverUrl, size: 48),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          track.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (track.isExplicit) ...[
                        const SizedBox(width: 8),
                        const ExplicitBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? track.artist?.name ?? 'Unknown',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onMoreTap != null)
              Bounceable(
                onTap: onMoreTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              )
            else
              Icon(
                Icons.play_arrow_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}
