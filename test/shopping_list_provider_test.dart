import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:precinho_app/presentation/providers/shopping_list_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('create list and add item', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shoppingListProvider.notifier);
    final listId = notifier.createList('Teste');
    notifier.addProductToList(
      listId: listId,
      productId: '1',
      productName: 'Banana',
      quantity: 2,
      price: 3,
      storeName: 'Comércio',
    );
    final list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.length, 1);
    expect(list.items.first.quantity, 2);
    final totals = notifier.totalsByStore(listId);
    expect(totals['Comércio'], 6);
  });

  test('update item price', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shoppingListProvider.notifier);
    final listId = notifier.createList('Teste');
    notifier.addProductToList(
      listId: listId,
      productId: '1',
      productName: 'Banana',
      quantity: 1,
    );
    notifier.updateItemPrice(
      listId: listId,
      productId: '1',
      price: 2.5,
      storeId: 's1',
      storeName: 'Comércio',
    );
    final list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.first.price, 2.5);
    expect(list.items.first.storeId, 's1');
  });

  test('clear item prices', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shoppingListProvider.notifier);
    final listId = notifier.createList('Teste');
    notifier.addProductToList(
      listId: listId,
      productId: '1',
      productName: 'Banana',
      quantity: 1,
      price: 2,
      storeId: 's1',
      storeName: 'Comércio',
    );

    notifier.clearPrices(listId);

    final list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.first.price, isNull);
    expect(list.items.first.storeId, isNull);
    expect(list.items.first.storeName, isNull);
  });

  test('toggle item completed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shoppingListProvider.notifier);
    final listId = notifier.createList('Teste');
    notifier.addProductToList(
      listId: listId,
      productId: '1',
      productName: 'Banana',
      quantity: 1,
    );

    final itemId = container
        .read(shoppingListProvider)
        .firstWhere((l) => l.id == listId)
        .items
        .first
        .id;

    notifier.toggleItemCompleted(listId: listId, itemId: itemId);
    var list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.first.isCompleted, isTrue);

    notifier.toggleItemCompleted(listId: listId, itemId: itemId);
    list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.first.isCompleted, isFalse);
  });

  test('remove item and delete list', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shoppingListProvider.notifier);
    final first = notifier.createList('L1');
    final second = notifier.createList('L2');
    notifier.addProductToList(
      listId: first,
      productId: '1',
      productName: 'Banana',
      quantity: 1,
    );

    final itemId = container
        .read(shoppingListProvider)
        .firstWhere((l) => l.id == first)
        .items
        .first
        .id;

    notifier.removeItem(listId: first, itemId: itemId);
    var list = container.read(shoppingListProvider).firstWhere((l) => l.id == first);
    expect(list.items, isEmpty);

    notifier.deleteList(first);
    final lists = container.read(shoppingListProvider);
    expect(lists.length, 1);
    expect(lists.first.id, second);
  });
}
