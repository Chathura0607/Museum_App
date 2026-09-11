import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Premium historical artifacts with rich descriptions, 3D models, and verified video guides
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask of Tutankhamun',
    nameSi: 'ටූටන්කාමුන් රජුගේ රන් මරණ මුහුණු ආවරණය',
    period: '1323 BC',
    year: '1323 BC',
    section: 'Ancient Egypt',
    location: 'Egyptian Treasures Wing, Hall 1',
    description: 'The iconic solid gold burial mask of 18th-dynasty Pharaoh Tutankhamun.',
    descriptionSi: '18 වන රාජවංශයේ ටූටන්කාමුන් පාරාවෝ රජුගේ ඓතිහාසික රන් මුහුණු ආවරණය.',
    details: 'The mask of Tutankhamun is a gold mask of the 18th-dynasty ancient Egyptian Pharaoh Tutankhamun. Discovered by Howard Carter in 1925 in tomb KV62, it is crafted from two layers of high-karat gold inlaid with colored glass and semiprecious gemstones including lapis lazuli, quartz, and obsidian. It weighs over 10.23 kilograms and features protective spells from the Book of the Dead.',
    detailsSi: 'ටූටන්කාමුන් රජුගේ මුහුණු ආවරණය යනු 18 වන රාජවංශයේ පුරාණ ඊජිප්තු පාරාවෝ ටූටන්කාමුන්ගේ රන් මුහුණු ආවරණයකි. එය 1925 දී හොවාර්ඩ් කාටර් විසින් KV62 සොහොන් ගැබේදී සොයා ගන්නා ලදී. එය කැරට් 18.4 සිට 22.5 දක්වා රත්‍රන් ස්ථර දෙකකින් නිමවා ඇති අතර බර කිලෝග්‍රෑම් 10 කට වඩා වැඩිය.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/c/c2/Tutankhamun_Mask.JPG&w=1200&fit=cover',
    modelUrl: 'https://sketchfab.com/models/ff2de7e040404a37825b2a0c40685714/embed',
    videoUrl: 'https://www.youtube.com/embed/UmL4uPn6xe0',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Legionary Gladius',
    nameSi: 'රෝම සොල්දාදු ග්ලැඩියස් කඩුව',
    period: '100–200 AD',
    year: '150 AD',
    section: 'Roman Empire',
    location: 'Imperial Rome Gallery, Hall 3',
    description: 'The standard-issue infantry sword that forged the mighty Roman Empire.',
    descriptionSi: 'රෝම අධිරාජ්‍යය ගොඩනැගූ පාබල හමුදා සොල්දාදුවන්ගේ ග්ලැඩියස් කඩුව.',
    details: 'The gladius was the primary weapon of Roman legionaries from the 3rd century BC until the 4th century AD. This specific "Mainz" pattern was designed for devastating thrusting combat in tight battle formations, featuring a carbon-steel blade and intricately carved bone and bronze hilt.',
    detailsSi: 'ග්ලැඩියස් යනු ක්‍රි.පූ. 3 වන සියවසේ සිට ක්‍රි.ව. 4 වන සියවස දක්වා පුරාණ රෝම පාබල සොල්දාදුවන්ගේ ප්‍රධාන කඩුව විය. සමීප සටන් වලදී වේගවත් ප්‍රහාර එල්ල කිරීම සඳහා මෙය නිර්මාණය කර ඇත.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/800px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/8a2b535d5a7d431ba2713f0607693635/embed',
    videoUrl: 'https://www.youtube.com/embed/9S8iM_27aR8',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'The Rosetta Stone',
    nameSi: 'රොසෙටා පාෂාණ ඵලකය',
    period: '196 BC',
    year: '196 BC',
    section: 'Ancient Egypt',
    location: 'Hieroglyphic Gallery, Hall 1',
    description: 'The monumental decree key that unlocked the secrets of Egyptian hieroglyphs.',
    descriptionSi: 'පුරාණ ඊජිප්තු හයිරොග්ලිෆ් අක්ෂර කියවීමේ රහස හෙළි කළ ඓතිහාසික රොසෙටා ගල.',
    details: 'The Rosetta Stone is a granodiorite stele inscribed with three versions of a decree issued in Memphis in 196 BC during the Ptolemaic dynasty. Because the decree appears in Ancient Egyptian hieroglyphs, Demotic script, and Ancient Greek, scholars like Jean-François Champollion deciphered ancient Egyptian writing.',
    detailsSi: 'රොසෙටා ගල යනු ක්‍රි.පූ. 196 දී ඊජිප්තුවේ මෙම්ෆිස් හි නිකුත් කරන ලද ආඥාවක් භාෂා ත්‍රිත්වයකින් (හයිරොග්ලිෆ්, ඩෙමොටික් සහ ග්‍රීක) කොටා ඇති ඵලකයකි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/2/23/Rosetta_Stone.JPG/1200px-Rosetta_Stone.JPG&w=1200',
    modelUrl: 'https://sketchfab.com/models/1e03509704a3490e99a173e53b93e282/embed',
    videoUrl: 'https://www.youtube.com/embed/V1v_6Yv8ZgU',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Aphrodite of Milos (Venus de Milo)',
    nameSi: 'වීනස් ද මයිලෝ ප්‍රතිමාව',
    period: '150–125 BC',
    year: '130 BC',
    section: 'Ancient Greece',
    location: 'Hellenistic Sculptures, Hall 2',
    description: 'One of the crowning masterworks of classical Greek marble sculpture.',
    descriptionSi: 'පුරාණ ග්‍රීක කලා ශිල්පයේ අග්‍රගන්‍ය කිරිගරුඬ ප්‍රතිමාවක්.',
    details: 'Discovered on the island of Milos in 1820, this celebrated Parian marble statue portrays Aphrodite, the goddess of love and beauty. Renowned for its subtle grace, serpentine silhouette, and enigmatic missing arms, it represents the pinnacle of Hellenistic sculpture.',
    detailsSi: 'වීනස් ද මයිලෝ යනු ලොව ප්‍රසිද්ධම පුරාණ ග්‍රීක ප්‍රතිමා වලින් එකකි. ක්‍රි.පූ. 150 ත් 125 ත් අතර කාලයේ නිර්මාණය වූ මෙය ප්‍රේමයට සහ රූපශ්‍රීයට අධිපති ඇෆ්‍රොඩයිට් දෙවඟන නිරූපණය කරයි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Venus_de_Milo_Louvre_Ma399_n4.jpg/800px-Venus_de_Milo_Louvre_Ma399_n4.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/49735d6e2e0443918a5f33366a3372c0/embed',
    videoUrl: 'https://www.youtube.com/embed/6tFfE6ZpXfA',
  ),
  Artifact(
    id: 'artifact_005',
    name: 'The Lewis Chessmen',
    nameSi: 'ලුවිස් චෙස් ක්‍රීඩා ඉත්තෝ',
    period: '12th Century AD',
    year: '1150 AD',
    section: 'Viking & Medieval',
    location: 'Nordic Heritage Wing, Hall 4',
    description: 'Intricately carved walrus ivory chess pieces depicting medieval royal courts.',
    descriptionSi: 'වොල්රස් ඇත්දළවලින් කැටයම් කරන ලද 12 වන සියවසේ සුවිශේෂී චෙස් ඉත්තන්.',
    details: 'Unearthed in 1831 on the Isle of Lewis in the Outer Hebrides of Scotland, these 78 expressive chess pieces were crafted in Trondheim, Norway. They feature wide-eyed kings, queens, bishops, knights, and berserker warriors biting their shields.',
    detailsSi: 'ලුවිස් චෙස් ක්‍රීඩකයෝ යනු ස්කොට්ලන්තයේ ලුවිස් දූපතෙන් හමුවූ නෝර්වීජියානු සම්භවයක් සහිත 12 වන සියවසේ චෙස් කට්ටලයකි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Lewis_Chessmen_British_Museum.jpg/1200px-Lewis_Chessmen_British_Museum.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/eddbebab12424c8aa610a21b9b7e19e5/embed',
    videoUrl: 'https://www.youtube.com/embed/oZBXTy5KK3I',
  ),
  Artifact(
    id: 'artifact_006',
    name: 'Apollo 11 Command Module Columbia',
    nameSi: 'ඇපලෝ 11 විධාන මොඩියුලය',
    period: '1969 AD',
    year: '1969 AD',
    section: 'Modern History & Space',
    location: 'Space Exploration Pavilion, Hall 5',
    description: 'The historic spacecraft that carried humanity to their first lunar landing.',
    descriptionSi: 'මිනිසා ප්‍රථම වරට සඳ මත පා තැබූ ඓතිහාසික ඇපලෝ 11 අභ්‍යවකාශ යානය.',
    details: 'The Command Module "Columbia" served as the living quarters and flight control hub for Neil Armstrong, Buzz Aldrin, and Michael Collins during the Apollo 11 lunar mission in July 1969. It was the only component of the spacecraft that returned safely to Earth.',
    detailsSi: 'ඇපලෝ 11 විධාන මොඩියුලය යනු 1969 ජූලි මාසයේදී මිනිසා ප්‍රථම වරට සඳ මතට ගෙන ගිය සහ නිරුපද්‍රිතව පෘථිවියට පැමිණි අභ්‍යවකාශ යානයයි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Apollo_11_Command_Module_Columbia_2022.jpg/1200px-Apollo_11_Command_Module_Columbia_2022.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/372bb6781922471cada4e0a9bd5c61fb/embed',
    videoUrl: 'https://www.youtube.com/embed/PwgDpGSm_n4',
  ),
];

// Initial pre-registered ticket passes for visitors and tests
final List<String> _initialTicketPasses = [
  'TKT-2026-09-11-001',
  'TKT-2026-09-11-002',
  'TKT-2026-09-11-003',
  'TKT-2026-09-11-004',
  'TKT-2026-09-11-005',
];

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  for (final artifact in _initialArtifacts) {
    final docRef = db.collection('artifacts').doc(artifact.id);
    batch.set(docRef, artifact.toMap()..['updatedAt'] = FieldValue.serverTimestamp(), SetOptions(merge: true));
  }

  for (final ticketId in _initialTicketPasses) {
    final ticketRef = db.collection('tickets').doc(ticketId);
    batch.set(ticketRef, {
      'usedBy': [],
      'isBlocked': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  await batch.commit();
}
