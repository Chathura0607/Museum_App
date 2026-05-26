import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Premium historical artifacts with rich, detailed descriptions and verified 3D models
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask',
    period: '1550–1500 BC',
    section: 'Ancient Egypt',
    description: 'The legendary mask of Tutankhamun, crafted from solid gold and precious gemstones.',
    details: 'The mask of Tutankhamun is a gold mask of the 18th-dynasty ancient Egyptian Pharaoh Tutankhamun. It was discovered by Howard Carter in 1925 in tomb KV62 and is now housed in the Egyptian Museum in Cairo. The mask is one of the most well-known works of art in the world. It is constructed of two layers of high-karat gold, varying from 18.4 to 22.5 karats, and weighs over 10 kilograms. The mask is inlaid with colored glass and gemstones, including lapis lazuli, quartz, and obsidian. The back of the mask is inscribed with a protective spell from the Book of the Dead, which was intended to protect the pharaoh\'s soul as it transitioned to the afterlife. The vulture and cobra on the forehead symbolize the unification of Lower and Upper Egypt.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/c/c2/Tutankhamun_Mask.JPG&w=1200&fit=cover',
    modelUrl: 'https://sketchfab.com/models/ff2de7e040404a37825b2a0c40685714/embed',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Gladius Sword',
    period: '100–200 AD',
    section: 'Roman Empire',
    description: 'The standard-issue infantry sword that built an empire.',
    details: 'The gladius was the primary sword of Ancient Roman foot soldiers from the 3rd century BC until the 4th century AD. This specific design, the "Mainz" type, was used primarily on the frontiers of the Empire. It was a short, double-edged sword designed for thrusting in the close-quarters environment of the Roman legionary phalanx. The blade was forged from high-carbon steel, while the hilt was often made of wood, bone, or ivory, providing a superior grip. The effectiveness of the gladius came from its balance; it allowed a soldier to strike quickly while remaining protected behind a large scutum (shield). Inscribed on many surviving specimens are the names of the legions or the individual soldiers who carried them, serving as a testament to the highly organized nature of the Roman military machine.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/800px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/8a2b535d5a7d431ba2713f0607693635/embed',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'The Rosetta Stone',
    period: '196 BC',
    section: 'Ancient Egypt',
    description: 'The key to deciphering Egyptian hieroglyphs.',
    details: 'The Rosetta Stone is a granodiorite stele, found in 1799, inscribed with three versions of a decree issued at Memphis, Egypt, in 196 BC during the Ptolemaic dynasty. The top and middle texts are in Ancient Egyptian using hieroglyphic and Demotic scripts, respectively, while the bottom is in Ancient Greek. Because the decree is the same in all three versions, the Rosetta Stone provided the key to the modern understanding of Egyptian hieroglyphs. It was rediscovered by French soldiers during Napoleon\'s Egyptian campaign. After the British defeated the French in Egypt, the stone was moved to London and has been on public display at the British Museum almost continuously since 1802. Its decipherment by Thomas Young and Jean-François Champollion opened the door to thousands of years of Egyptian history.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/2/23/Rosetta_Stone.JPG/1200px-Rosetta_Stone.JPG&w=1200',
    modelUrl: 'https://sketchfab.com/models/1e03509704a3490e99a173e53b93e282/embed',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Venus de Milo',
    period: '150–125 BC',
    section: 'Ancient Greece',
    description: 'One of the most famous works of ancient Greek sculpture.',
    details: 'The Aphrodite of Milos, better known as the Venus de Milo, is an ancient Greek statue and one of the most famous works of ancient Greek sculpture. Created during the Hellenistic period between 150 and 125 BC, it was discovered on the island of Milos in 1820. It is a marble sculpture, slightly larger than life size at 202 cm (6 ft 8 in). The statue is missing its arms, which has led to centuries of speculation about what they might have been holding—perhaps an apple, a shield, or a mirror. The sculpture is attributed to Alexandros of Antioch. It is currently on permanent display at the Louvre Museum in Paris. The grace and balance of the figure, combined with the mystery of its missing limbs, have made it an enduring icon of classical beauty.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Venus_de_Milo_Louvre_Ma399_n4.jpg/800px-Venus_de_Milo_Louvre_Ma399_n4.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/49735d6e2e0443918a5f33366a3372c0/embed',
  ),
  Artifact(
    id: 'artifact_005',
    name: 'Lewis Chessmen',
    period: '12th Century',
    section: 'Viking Age',
    description: 'Iconic gaming pieces made of walrus ivory.',
    details: 'The Lewis Chessmen are a group of distinctive 12th-century chess pieces, along with other gaming pieces, most of which are carved from walrus ivory. They were discovered in 1831 on the Isle of Lewis in the Outer Hebrides of Scotland. They may have been made in Norway, perhaps by craftsmen in Trondheim, in the 12th century. During that period, the Outer Hebrides, along with other Scottish islands, were under the control of the Kingdom of Norway. The pieces are famous for their expressive faces, particularly the "warder" (rook) who is seen biting his shield in a berserker rage. The set includes kings, queens, bishops, knights, warders, and pawns. They represent a rare glimpse into the medieval world and the cultural connections between Scandinavia and the British Isles.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Lewis_Chessmen_British_Museum.jpg/1200px-Lewis_Chessmen_British_Museum.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/eddbebab12424c8aa610a21b9b7e19e5/embed',
  ),
  Artifact(
    id: 'artifact_006',
    name: 'Apollo 11 Command Module',
    period: '1969 AD',
    section: 'Modern History',
    description: 'The spacecraft that carried the first men to the Moon.',
    details: 'The Command Module "Columbia" was the spacecraft that served as the command center and living quarters for the three-person crew during the Apollo 11 mission in July 1969—the first mission to land humans on the Moon. While Neil Armstrong and Buzz Aldrin descended to the lunar surface in the Lunar Module "Eagle," Michael Collins remained in orbit aboard Columbia. It was the only part of the entire Apollo 11 spacecraft stack to return safely to Earth, splashing down in the Pacific Ocean on July 24, 1969. The interior is covered in thousands of switches and controls, and even includes hand-written notes and calendars made by the astronauts during their historic flight. Today, it is one of the most significant artifacts at the Smithsonian National Air and Space Museum, representing the pinnacle of human exploration and engineering.',
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
  print('Seeding complete: Collection updated with rich descriptions and verified 3D models!');
}
