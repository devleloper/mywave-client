class Artist {
  final String id;
  final String name;
  final String? pictureUrl;
  final int? fans;

  const Artist({
    required this.id,
    required this.name,
    this.pictureUrl,
    this.fans,
  });
}
