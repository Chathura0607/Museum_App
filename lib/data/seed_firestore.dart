import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Using high-quality "studio-style" URLs for a premium look
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask',
    period: '1550–1500 BC',
    section: 'Ancient Egypt',
    description: 'The legendary mask of Tutankhamun, crafted from solid gold and precious gemstones.',
    details: '''One of the most famous works of art in history, this funeral mask was discovered in the tomb of the young pharaoh Tutankhamun. It is constructed of two layers of high-karat gold, inlaid with lapis lazuli, turquoise, and obsidian. The mask represents the pharaoh as Osiris, god of the afterlife.''',
    // NEW DRAMATIC STUDIO IMAGE
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/c/c2/Tutankhamun_Mask.JPG&w=1200&fit=cover',
    modelUrl: 'https://sketchfab.com/models/0d680327f12e457f9752df22c91a039d/embed',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Gladius Sword',
    period: '100–200 AD',
    section: 'Roman Empire',
    description: 'The standard-issue infantry sword that built an empire.',
    details: '''The Gladius Hispaniensis was the primary weapon of the Roman legionary. Known for its efficiency in close-quarters combat, this specimen features a high-carbon steel blade and a bone hilt with intricate decorative carvings.''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/800px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/788c6913797641d48d08560f73f15b6b/embed',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'Ming Dynasty Vase',
    period: '1368–1644 AD',
    section: 'Ancient China',
    description: 'Exquisite cobalt-blue porcelain representing the pinnacle of ceramic art.',
    details: '''This porcelain vase dates to the Xuande period. It features a continuous landscape motif with pine trees and cranes, symbols of longevity. The vibrant blue pigment was imported via the Silk Road from Persia.''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Ming_dynasty_vase.jpg/800px-Ming_dynasty_vase.jpg',
    modelUrl: 'https://sketchfab.com/models/f5757973715f403c9b7e7a57a07010f3/embed',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Viking Runestone',
    period: '800–1100 AD',
    section: 'Viking Age',
    description: 'A monument to honor the fallen, inscribed with ancient Norse runes.',
    details: '''Erected in the late Viking Age, this granite stone commemorates a chieftain who traveled to distant lands. The serpentine inscriptions tell a tale of bravery and honor across the Northern seas.''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Runestone_Gs_13.jpg/800px-Runestone_Gs_13.jpg',
    modelUrl: 'https://sketchfab.com/models/80c85c2901a84f378037303f8a092822/embed',
  ),
];

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  for (final artifact in _initialArtifacts) {
    final docRef = db.collection('artifacts').doc(artifact.id);
    batch.set(docRef, {
      'name': artifact.name,
      'period': artifact.period,
      'section': artifact.section,
      'description': artifact.description,
      'details': artifact.details,
      'imageUrl': artifact.imageUrl,
      'modelUrl': artifact.modelUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  await batch.commit();
  print('Seeding complete: All artifacts updated with premium visuals!');
}
