import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/db/providers.dart';
import 'package:re_mind/features/settings/presentation/pro_status.dart';

import '../../support/app_test_harness.dart';

class FakeBilling implements BillingService {
  final scheduled = <String>[];
  bool throwOnBuy = false;
  int restores = 0;

  @override
  Future<ProductDetails?> loadProduct() async => ProductDetails(
        id: proProductId,
        title: 'Pro',
        description: '',
        price: '\$6.99',
        rawPrice: 6.99,
        currencyCode: 'USD',
        currencySymbol: '\$',
      );

  @override
  Future<void> buy(ProductDetails product) async {
    if (throwOnBuy) throw Exception('store down');
    scheduled.add(product.id);
  }

  @override
  Future<void> restore() async {
    restores++;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late AppDatabase db;
  late FakeBilling billing;

  setUp(() {
    db = createInMemoryDb();
    billing = FakeBilling();
  });
  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          billingProvider.overrideWithValue(billing),
        ],
      );

  test('entitlement defaults to false, grant persists, load restores',
      () async {
    final c1 = container();
    addTearDown(c1.dispose);
    final n1 = c1.read(proStatusProvider.notifier);
    await n1.load();
    expect(c1.read(proStatusProvider), false);

    await n1.grant();
    expect(c1.read(proStatusProvider), true);

    // Fresh notifier over the same db restores the entitlement
    // deterministically via the explicit load() entry point.
    final c2 = container();
    addTearDown(c2.dispose);
    final n2 = c2.read(proStatusProvider.notifier);
    expect(c2.read(proStatusProvider), false); // not loaded yet
    await n2.load();
    expect(c2.read(proStatusProvider), true);
  });

  test('controller buy launches purchase without granting directly',
      () async {
    final c = container();
    addTearDown(c.dispose);
    final controller = ProPurchaseController(billing);

    final product = (await billing.loadProduct())!;
    final err = await controller.buy(product);

    expect(err, isNull);
    expect(billing.scheduled, [proProductId]);
    expect(c.read(proStatusProvider), false); // grant via verified callback
  });

  test('store errors surface as error key without crashing', () async {
    final c = container();
    addTearDown(c.dispose);
    billing.throwOnBuy = true;
    final controller = ProPurchaseController(billing);

    final err = await controller.buy((await billing.loadProduct())!);
    expect(err, 'error');
  });

  test('restore asks the store; grant still via verified callback',
      () async {
    final c = container();
    addTearDown(c.dispose);
    final controller = ProPurchaseController(billing);

    await controller.restore();
    expect(billing.restores, 1);
  });
}
