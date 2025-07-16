import 'package:flutter_test/flutter_test.dart';
import 'package:precinho_app/domain/entities/price.dart';
import 'package:precinho_app/core/constants/enums.dart';

void main() {
  test('copyWith and computed getters', () {
    final now = DateTime.now();
    final price = Price(
      id: '1',
      productId: 'p1',
      storeId: 's1',
      userId: 'u1',
      value: 10,
      productName: 'Banana',
      storeName: 'Comércio',
      createdAt: now.subtract(const Duration(days: 2)),
      status: ModerationStatus.approved,
      updatedAt: now,
      isPromotional: true,
    );

    final updated = price.copyWith(value: 12);
    expect(updated.value, 12);
    expect(price.isActive, isTrue);
    expect(price.copyWith(isActive: false).isActive, isFalse);

    expect(price.hasImage, isFalse);
    expect(price.formattedValue, 'R\$ 10,00');
    expect(price.ageInDays >= 2, isTrue);
  });

  test('isExpired should reflect expiresAt', () {
    final now = DateTime.now();
    final price = Price(
      id: '1',
      productId: 'p1',
      storeId: 's1',
      userId: 'u1',
      value: 10,
      productName: 'Banana',
      storeName: 'Comércio',
      createdAt: now.subtract(const Duration(days: 10)),
      expiresAt: now.subtract(const Duration(days: 1)),
      status: ModerationStatus.approved,
      updatedAt: now,
      isPromotional: false,
    );

    expect(price.isExpired, isTrue);
  });
}
