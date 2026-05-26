class Artifact {
  final String id;
  final String name;
  final String period;
  final String description;
  final String details;
  final String section;
  final String imageUrl;
  final String? modelUrl;
  final String? descriptionSi;
  final String? detailsSi;

  const Artifact({
    required this.id,
    required this.name,
    required this.period,
    required this.description,
    required this.details,
    required this.section,
    required this.imageUrl,
    this.modelUrl,
    this.descriptionSi,
    this.detailsSi,
  });
}
