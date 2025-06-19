import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precinho_app/presentation/providers/store_favorites_provider.dart';

void main() {
  test('toggle favorite adds and removes store', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(storeFavoritesProvider.notifier);

    expect(container.read(storeFavoritesProvider).contains('1'), isFalse);

    notifier.toggleFavorite('1');
    expect(container.read(storeFavoritesProvider).contains('1'), isTrue);

    notifier.toggleFavorite('1');
    expect(container.read(storeFavoritesProvider).contains('1'), isFalse);
  });
}
