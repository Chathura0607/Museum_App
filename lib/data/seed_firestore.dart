import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Using the data provided by the user, wrapped with weserv proxy to avoid CORS errors on Chrome
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask',
    period: '1550–1500 BC',
    section: 'Ancient Egypt',
    description: 'A stunning funeral mask crafted from pure gold leaf.',
    details: '''The Golden Death Mask is one of the most remarkable artifacts from ancient Egypt. Discovered in the Valley of the Kings in 1922, this mask was placed over the face of a mummified pharaoh to protect the soul during its journey to the afterlife.

Crafted from pure gold leaf with inlaid gemstones including lapis lazuli and obsidian, the mask weighs approximately 10 kilograms. The craftsmanship reflects the extraordinary skill of ancient Egyptian artisans who worked exclusively for the royal court.

The hieroglyphs inscribed along the collar translate to: "Thy soul is prepared, thy heart is at peace. Thou art protected for eternity."''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/2/27/CairoEgMuseumTaaMaskMostlyPhotographed.jpg/400px-CairoEgMuseumTaaMaskMostlyPhotographed.jpg',
    modelUrl: 'https://sketchfab.com/models/0d680327f12e457f9752df22c91a039d/embed',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Gladius Sword',
    period: '100–200 AD',
    section: 'Roman Empire',
    description: 'A standard issue short sword carried by Roman legionaries.',
    details: '''The Gladius was the primary weapon of the Roman legionary soldier for over 400 years. This particular specimen was unearthed near Hadrian\'s Wall in northern England, suggesting it belonged to a soldier stationed at the frontier of the Roman Empire.

The blade measures 50cm in length and is forged from high-carbon steel using techniques that were remarkably advanced for the era. The hilt is wrapped in bone and leather, providing a firm grip in battle conditions.

Inscribed on the blade is the soldier\'s name — Lucius Petronius — and his legion number, the Legio VI Victrix, meaning "Victorious Sixth Legion."''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/300px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/788c6913797641d48d08560f73f15b6b/embed',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'Ming Dynasty Vase',
    period: '1368–1644 AD',
    section: 'Ancient China',
    description: 'A porcelain vase featuring the iconic blue and white design.',
    details: '''This exquisite porcelain vase was produced during the reign of the Xuande Emperor in the Ming Dynasty, one of the most celebrated periods of Chinese ceramic art. The distinctive cobalt blue designs on white porcelain became so iconic that "Ming vase" became synonymous with fine Chinese ceramics worldwide.

The vase stands 45cm tall and depicts a continuous landscape scene featuring mountains, pine trees, and cranes — all symbols of longevity and good fortune in Chinese culture. The cobalt pigment was imported from Persia along the Silk Road.

Only 12 vases of this exact design are known to exist worldwide, making this piece extraordinarily rare and valuable.''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Ming_dynasty_vase.jpg/300px-Ming_dynasty_vase.jpg',
    modelUrl: 'https://sketchfab.com/models/f5757973715f403c9b7e7a57a07010f3/embed',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Viking Runestone',
    period: '800–1100 AD',
    section: 'Viking Age',
    description: 'A carved stone tablet inscribed with ancient Norse runes.',
    details: '''This runestone was discovered in Uppland, Sweden in 1887 and dates to the late Viking Age. Runestones were typically erected as memorials to the dead, and this one commemorates a Viking chieftain named Sigurd who "fell in the east" — likely during a raid or trading expedition to Russia or Byzantium.

The runic inscription reads: "Astrid and Halvard raised this stone in memory of Sigurd, their father, who travelled far and died with honour."

The stone also bears a carved serpent motif typical of the Urnes style, one of the last and most refined styles of Viking art.''',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Runestone_Gs_13.jpg/300px-Runestone_Gs_13.jpg',
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
  print('Seeding complete: Provided artifacts data successfully added to Firestore!');
}
