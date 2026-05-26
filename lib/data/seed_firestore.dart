import 'package:cloud_firestore/cloud_firestore.dart';
import 'museum_data.dart';

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  for (final artifact in artifacts) {
    await db.collection('artifacts').doc(artifact.id).set({
      'name': artifact.name,
      'period': artifact.period,
      'section': artifact.section,
      'description': artifact.description,
      'details': artifact.details,
      'imageUrl': artifact.imageUrl,
    });
  }
  print('Seeding complete!');
}
