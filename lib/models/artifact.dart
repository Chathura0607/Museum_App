import 'package:cloud_firestore/cloud_firestore.dart';

class Artifact {
  final String id;
  final String name;
  final String? nameSi;
  final String period;
  final String? year;
  final String description;
  final String? descriptionSi;
  final String details;
  final String? detailsSi;
  final String section;
  final String? location;
  final String imageUrl;
  final String? modelUrl;
  final String? videoUrl;
  final String? audioUrl;
  final bool isFavorite;

  const Artifact({
    required this.id,
    required this.name,
    this.nameSi,
    required this.period,
    this.year,
    required this.description,
    this.descriptionSi,
    required this.details,
    this.detailsSi,
    required this.section,
    this.location,
    required this.imageUrl,
    this.modelUrl,
    this.videoUrl,
    this.audioUrl,
    this.isFavorite = false,
  });

  factory Artifact.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Artifact.fromMap(data, doc.id);
  }

  factory Artifact.fromMap(Map<String, dynamic> data, String id) {
    return Artifact(
      id: id,
      name: (data['name'] ?? '').toString(),
      nameSi: data['nameSi']?.toString(),
      period: (data['period'] ?? '').toString(),
      year: data['year']?.toString(),
      description: (data['description'] ?? '').toString(),
      descriptionSi: data['descriptionSi']?.toString(),
      details: (data['details'] ?? '').toString(),
      detailsSi: data['detailsSi']?.toString(),
      section: (data['section'] ?? '').toString(),
      location: data['location']?.toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      modelUrl: data['modelUrl']?.toString(),
      videoUrl: data['videoUrl']?.toString(),
      audioUrl: data['audioUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (nameSi != null) 'nameSi': nameSi,
      'period': period,
      if (year != null) 'year': year,
      'description': description,
      if (descriptionSi != null) 'descriptionSi': descriptionSi,
      'details': details,
      if (detailsSi != null) 'detailsSi': detailsSi,
      'section': section,
      if (location != null) 'location': location,
      'imageUrl': imageUrl,
      if (modelUrl != null) 'modelUrl': modelUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (audioUrl != null) 'audioUrl': audioUrl,
    };
  }

  Artifact copyWith({
    String? id,
    String? name,
    String? nameSi,
    String? period,
    String? year,
    String? description,
    String? descriptionSi,
    String? details,
    String? detailsSi,
    String? section,
    String? location,
    String? imageUrl,
    String? modelUrl,
    String? videoUrl,
    String? audioUrl,
    bool? isFavorite,
  }) {
    return Artifact(
      id: id ?? this.id,
      name: name ?? this.name,
      nameSi: nameSi ?? this.nameSi,
      period: period ?? this.period,
      year: year ?? this.year,
      description: description ?? this.description,
      descriptionSi: descriptionSi ?? this.descriptionSi,
      details: details ?? this.details,
      detailsSi: detailsSi ?? this.detailsSi,
      section: section ?? this.section,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      modelUrl: modelUrl ?? this.modelUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
