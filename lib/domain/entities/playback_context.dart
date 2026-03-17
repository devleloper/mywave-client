class PlaybackContext {
  final PlaybackContextType type;
  final String id;

  const PlaybackContext({
    required this.type,
    required this.id,
  });
}

enum PlaybackContextType {
  album,
  artist,
  collection,
  search,
}
