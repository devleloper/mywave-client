class Lyrics {
  final String? synced;
  final String? plain;
  final String source;

  const Lyrics({
    this.synced,
    this.plain,
    required this.source,
  });

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      synced: json['synced'] as String?,
      plain: json['plain'] as String?,
      source: json['source'] as String? ?? 'UNKNOWN',
    );
  }
}
