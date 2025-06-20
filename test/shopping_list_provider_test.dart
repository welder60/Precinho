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
      storeName: 'Loja',
    );
    final list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.length, 1);
    expect(list.items.first.quantity, 2);
    final totals = notifier.totalsByStore(listId);
    expect(totals['Loja'], 6);
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
      storeName: 'Loja',
    );
    final list = container.read(shoppingListProvider).firstWhere((l) => l.id == listId);
    expect(list.items.first.price, 2.5);
    expect(list.items.first.storeId, 's1');
  });
}
