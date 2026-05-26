import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artifact.dart';

// Premium historical artifacts with rich, detailed descriptions in English and Sinhala
final List<Artifact> _initialArtifacts = [
  Artifact(
    id: 'artifact_001',
    name: 'Golden Death Mask',
    nameSi: 'රන් මුහුණු ආවරණය',
    descriptionSi: 'ටූටන්කාමුන් රජුගේ රන් මුහුණු ආවරණය.',
    period: '1550–1500 BC',
    section: 'Ancient Egypt',
    description: 'The legendary mask of Tutankhamun, crafted from solid gold and precious gemstones.',
    details: 'The mask of Tutankhamun is a gold mask of the 18th-dynasty ancient Egyptian Pharaoh Tutankhamun. It was discovered by Howard Carter in 1925 in tomb KV62 and is now housed in the Egyptian Museum in Cairo. The mask is one of the most well-known works of art in the world. It is constructed of two layers of high-karat gold, varying from 18.4 to 22.5 karats, and weighs over 10 kilograms. The mask is inlaid with colored glass and gemstones, including lapis lazuli, quartz, and obsidian. The back of the mask is inscribed with a protective spell from the Book of the Dead, which was intended to protect the pharaoh\'s soul as it transitioned to the afterlife. The vulture and cobra on the forehead symbolize the unification of Lower and Upper Egypt.',
    detailsSi: 'ටූටන්කාමුන් රජුගේ මුහුණු ආවරණය යනු 18 වන රාජවංශයේ පුරාණ ඊජිප්තු පාරාවෝ ටූටන්කාමුන්ගේ රන් මුහුණු ආවරණයකි. එය 1925 දී හොවාර්ඩ් කාටර් විසින් KV62 සොහොන් ගැබේදී සොයා ගන්නා ලද අතර දැන් එය කයිරෝ හි ඊජිප්තු කෞතුකාගාරයේ තබා ඇත. මෙම මුහුණු ආවරණය ලෝකයේ වඩාත්ම ප්‍රසිද්ධ කලා කෘතිවලින් එකකි. එය රත්‍රන් ස්ථර දෙකකින් නිමවා ඇති අතර බර කිලෝග්‍රෑම් 10 කට වඩා වැඩිය. නළලේ ඇති ගිජුලිහිණියා සහ නයා පහළ සහ ඉහළ ඊජිප්තුවේ ඒකාබද්ධතාවය සංකේතවත් කරයි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/c/c2/Tutankhamun_Mask.JPG&w=1200&fit=cover',
    modelUrl: 'https://sketchfab.com/models/ff2de7e040404a37825b2a0c40685714/embed',
  ),
  Artifact(
    id: 'artifact_002',
    name: 'Roman Gladius Sword',
    nameSi: 'රෝම ග්ලැඩියස් කඩුව',
    descriptionSi: 'රෝම සොල්දාදුවන් භාවිතා කළ ග්ලැඩියස් කඩුව.',
    period: '100–200 AD',
    section: 'Roman Empire',
    description: 'The standard-issue infantry sword that built an empire.',
    details: 'The gladius was the primary sword of Ancient Roman foot soldiers from the 3rd century BC until the 4th century AD. This specific design, the "Mainz" type, was used primarily on the frontiers of the Empire. It was a short, double-edged sword designed for thrusting in the close-quarters environment of the Roman legionary phalanx. The blade was forged from high-carbon steel, while the hilt was often made of wood, bone, or ivory, providing a superior grip. The effectiveness of the gladius came from its balance; it allowed a soldier to strike quickly while remaining protected behind a large scutum (shield).',
    detailsSi: 'ග්ලැඩියස් යනු ක්‍රි.පූ. 3 වන සියවසේ සිට ක්‍රි.ව. 4 වන සියවස දක්වා පුරාණ රෝම පාබල සොල්දාදුවන්ගේ ප්‍රධාන කඩුව විය. මෙම සැලසුම අධිරාජ්‍යයේ දේශසීමා වල ප්‍රධාන වශයෙන් භාවිතා කරන ලදී. එය සමීප සටන් සඳහා නිර්මාණය කරන ලද කෙටි, දාර දෙකේ කඩුවකි. තලය ඉහළ කාබන් වානේ වලින් සාදා ඇති අතර මිට බොහෝ විට ලී, අස්ථි හෝ ඇත්දළ වලින් සාදා ඇත.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Mainz_gladius.jpg/800px-Mainz_gladius.jpg',
    modelUrl: 'https://sketchfab.com/models/8a2b535d5a7d431ba2713f0607693635/embed',
  ),
  Artifact(
    id: 'artifact_003',
    name: 'The Rosetta Stone',
    nameSi: 'රොසෙටා ගල',
    descriptionSi: 'ඊජිප්තු හයිරොග්ලිෆ් අක්ෂර කියවීමට මග පෑදු රොසෙටා ගල.',
    period: '196 BC',
    section: 'Ancient Egypt',
    description: 'The key to deciphering Egyptian hieroglyphs.',
    details: 'The Rosetta Stone is a granodiorite stele, found in 1799, inscribed with three versions of a decree issued at Memphis, Egypt, in 196 BC during the Ptolemaic dynasty. The top and middle texts are in Ancient Egyptian using hieroglyphic and Demotic scripts, respectively, while the bottom is in Ancient Greek. Because the decree is the same in all three versions, the Rosetta Stone provided the key to the modern understanding of Egyptian hieroglyphs.',
    detailsSi: 'රොසෙටා ගල යනු ක්‍රි.පූ. 196 දී ඊජිප්තුවේ මෙම්ෆිස් හි නිකුත් කරන ලද ආඥාවක සංස්කරණ තුනක් කොටා ඇති ගලකි. මෙහි ඉහළ සහ මැද පෙළ පුරාණ ඊජිප්තු හයිරොග්ලිෆ් සහ ඩිමොටික් අක්ෂර වලින්ද, පහළ පෙළ පුරාණ ග්‍රීක භාෂාවෙන්ද ඇත. මෙමගින් පුරාණ ඊජිප්තු අක්ෂර කියවීමට මග පෑදුනි.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/2/23/Rosetta_Stone.JPG/1200px-Rosetta_Stone.JPG&w=1200',
    modelUrl: 'https://sketchfab.com/models/1e03509704a3490e99a173e53b93e282/embed',
  ),
  Artifact(
    id: 'artifact_004',
    name: 'Venus de Milo',
    nameSi: 'වීනස් ද මයිලෝ',
    descriptionSi: 'ප්‍රසිද්ධ පුරාණ ග්‍රීක ප්‍රතිමාවකි.',
    period: '150–125 BC',
    section: 'Ancient Greece',
    description: 'One of the most famous works of ancient Greek sculpture.',
    details: 'The Aphrodite of Milos, better known as the Venus de Milo, is an ancient Greek statue and one of the most famous works of ancient Greek sculpture. Created during the Hellenistic period between 150 and 125 BC, it was discovered on the island of Milos in 1820. It is a marble sculpture, slightly larger than life size at 202 cm (6 ft 8 in). The statue is missing its arms, which has led to centuries of speculation about what they might have been holding.',
    detailsSi: 'වීනස් ද මයිලෝ යනු ලොව ප්‍රසිද්ධම පුරාණ ග්‍රීක ප්‍රතිමා වලින් එකකි. ක්‍රි.පූ. 150 ත් 125 ත් අතර කාලය තුළ නිර්මාණය කරන ලද මෙය 1820 දී මයිලෝස් දූපතේදී සොයා ගන්නා ලදී. මෙය කිරිගරුඬින් නෙළන ලද ප්‍රතිමාවකි. මෙහි දෑත් අහිමි වී ඇති අතර එය අතීතයේ සිටම විවිධ මත වලට හේතු වී ඇත.',
    imageUrl: 'https://images.weserv.nl/?url=upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Venus_de_Milo_Louvre_Ma399_n4.jpg/800px-Venus_de_Milo_Louvre_Ma399_n4.jpg&w=1200',
    modelUrl: 'https://sketchfab.com/models/49735d6e2e0443918a5f33366a3372c0/embed',
  ),
];

Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();
  for (final artifact in _initialArtifacts) {
    final docRef = db.collection('artifacts').doc(artifact.id);
    batch.set(docRef, {
      'name': artifact.name,
      'nameSi': artifact.nameSi,
      'period': artifact.period,
      'section': artifact.section,
      'description': artifact.description,
      'descriptionSi': artifact.descriptionSi,
      'details': artifact.details,
      'detailsSi': artifact.detailsSi,
      'imageUrl': artifact.imageUrl,
      'modelUrl': artifact.modelUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  await batch.commit();
  print('Seeding complete: Collection updated with Sinhala translations and nameSi!');
}
