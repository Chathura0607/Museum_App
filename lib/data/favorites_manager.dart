import 'package:flutter/foundation.dart';

class FavoritesManager {
  FavoritesManager._internal();
  static final FavoritesManager instance = FavoritesManager._internal();

  final ValueNotifier<Set<String>> favoriteIdsNotifier = ValueNotifier<Set<String>>({});

  Set<String> get favoriteIds => favoriteIdsNotifier.value;

  bool isFavorite(String artifactId) => favoriteIds.contains(artifactId);

  void toggleFavorite(String artifactId) {
    final current = Set<String>.from(favoriteIdsNotifier.value);
    if (current.contains(artifactId)) {
      current.remove(artifactId);
    } else {
      current.add(artifactId);
    }
    favoriteIdsNotifier.value = current;
  }
}
