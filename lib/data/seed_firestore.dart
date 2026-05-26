import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Premium historical artifacts with high-quality images and verified 3D models
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask',
    period: '1550–1500 BC',
    section: 'Ancient Egypt',
    description: 'The legendary mask of Tutankhamun, crafted from solid gold and precious gemstones.',
    details: 'One of the most famous works of art in history, this funeral mask was discovered in the tomb of the young pharaoh Tutankhamun. It is constructed of two layers of high-karat gold, inlaid with lapis lazuli, turquoise, and obsidian. The mask represents the pharaoh as Osiris, god of the afterlife.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/c/c2/Tutankhamun_Mask.JPG&w=1200&fit=cover',
    modelUrl: 'https://sketchfab.com/models/ff2de7e040404a37825b2a0c40685714/embed',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Gladius Sword',
    period: '100–200 AD',
    section: 'Roman Empire',
    description: 'The standard-issue infantry sword that built an empire.',
    details: 'The Gladius Hispaniensis was the primary weapon of the Roman legionary. Known for its efficiency in close-quarters combat, this specimen features a high-carbon steel blade and a bone hilt with intricate decorative carvings.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/800px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/8a2b535d5a7d431ba2713f0607693635/embed',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'The Rosetta Stone',
    period: '196 BC',
    section: 'Ancient Egypt',
    description: 'The key to deciphering Egyptian hieroglyphs.',
    details: 'This granodiorite stele is inscribed with three versions of a decree issued in Memphis, Egypt. The top and middle texts are in Ancient Egyptian using hieroglyphic and Demotic scripts, while the bottom is in Ancient Greek. It provided the first modern key to understanding Egyptian hieroglyphs.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/2/23/Rosetta_Stone.JPG/1200px-Rosetta_Stone.JPG&w=1200',
    modelUrl: 'https://sketchfab.com/models/1e03509704a3490e99a173e53b93e282/embed',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Venus de Milo',
    period: '150–125 BC',
    section: 'Ancient Greece',
    description: 'One of the most famous works of ancient Greek sculpture.',
    details: 'The Aphrodite of Milos is an ancient Greek statue and one of the most famous works of ancient Greek sculpture. Created during the Hellenistic period, it is believed to depict Aphrodite, the Greek goddess of love and beauty.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Venus_de_Milo_Louvre_Ma399_n4.jpg/800px-Venus_de_Milo_Louvre_Ma399_n4.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/49735d6e2e0443918a5f33366a3372c0/embed',
  ),
  Artifact(
    id: 'artifact_005',
    name: 'Lewis Chessmen',
    period: '12th Century',
    section: 'Viking Age',
    description: 'Iconic gaming pieces made of walrus ivory.',
    details: 'The Lewis Chessmen are a group of 12th-century ivory chess pieces and other gaming pieces, most of which are carved from walrus ivory. They were discovered in 1831 on the Isle of Lewis in the Outer Hebrides, Scotland.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Lewis_Chessmen_British_Museum.jpg/1200px-Lewis_Chessmen_British_Museum.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/eddbebab12424c8aa610a21b9b7e19e5/embed',
  ),
  Artifact(
    id: 'artifact_006',
    name: 'Apollo 11 Command Module',
    period: '1969 AD',
    section: 'Modern History',
    description: 'The spacecraft that carried the first men to the Moon.',
    details: 'The Command Module Columbia was the living quarters for the three-person crew during most of the first crewed lunar landing mission in July 1969. It was the only part of the Apollo 11 spacecraft that returned to Earth.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Apollo_11_Command_Module_Columbia_2022.jpg/1200px-Apollo_11_Command_Module_Columbia_2022.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/372bb6781922471cada4e0a9bd5c61fb/embed',
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
  print('Seeding complete: Collection updated with verified 3D models!');
}
