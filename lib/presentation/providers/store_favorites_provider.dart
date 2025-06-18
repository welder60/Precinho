import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreFavoritesNotifier extends StateNotifier<Set<String>> {
  StoreFavoritesNotifier() : super(<String>{});

  void toggleFavorite(String storeId) {
    if (state.contains(storeId)) {
      state = {...state}..remove(storeId);
    } else {
      state = {...state, storeId};
    }
  }

  bool isFavorite(String storeId) => state.contains(storeId);
}

final storeFavoritesProvider =
    StateNotifierProvider<StoreFavoritesNotifier, Set<String>>(
        (ref) => StoreFavoritesNotifier());
