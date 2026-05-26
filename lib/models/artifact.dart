class Artifact {
  final String id;
  final String name;
  final String period;
  final String? year;
  final String description;
  final String details;
  final String section;
  final String? location;
  final String imageUrl;
  final String? modelUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? descriptionSi;
  final String? detailsSi;
  final String? nameSi;

  const Artifact({
    required this.id,
    required this.name,
    required this.period,
    this.year,
    required this.description,
    required this.details,
    required this.section,
    this.location,
    required this.imageUrl,
    this.modelUrl,
    this.videoUrl,
    this.audioUrl,
    this.descriptionSi,
    this.detailsSi,
    this.nameSi,
  });
}
