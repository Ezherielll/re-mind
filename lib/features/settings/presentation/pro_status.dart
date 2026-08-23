import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/db/providers.dart';
import '../../../core/db/settings_dao.dart';

const proProductId = 're_mind_pro_lifetime';

/// Billing seam so entitlement flows are testable without platform
/// channels (ADR-0009).
abstract class BillingService {
  /// Loads the lifetime SKU; null when the store is unreachable.
  Future<ProductDetails?> loadProduct();

  /// Launches the non-consumable purchase flow.
  Future<void> buy(ProductDetails product);

  /// Asks the store to re-deliver past purchases.
  Future<void> restore();

  Future<void> dispose();
}

/// Production wrapper over in_app_purchase. Purchase completions grant the
/// entitlement through [onPurchased].
class RealBillingService implements BillingService {
  RealBillingService(this._onVerifiedPurchase);

  final void Function() _onVerifiedPurchase;
  late final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  ProductDetails? lastSeenProduct;

  Future<RealBillingService> init() async {
    _iap = InAppPurchase.instance;
    if (!await _iap.isAvailable()) return this;
    _sub = _iap.purchaseStream.listen(
      (purchases) {
        for (final p in purchases) {
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            if (p.productID == proProductId) _onVerifiedPurchase();
          }
          if (p.pendingCompletePurchase) {
            _iap.completePurchase(p);
          }
        }
      },
      onError: (_) {},
    );
    final response = await _iap.queryProductDetails({proProductId});
    if (response.notFoundIDs.isEmpty && response.productDetails.isNotEmpty) {
      lastSeenProduct = response.productDetails.first;
    }
    return this;
  }

  @override
  Future<ProductDetails?> loadProduct() async => lastSeenProduct;

  @override
  Future<void> buy(ProductDetails product) async {
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
  }
}

/// Whether the user owns the lifetime Pro unlock; persisted in AppSettings
/// so it survives restarts and reinstalls-with-restore.
class ProStatus extends Notifier<bool> {
  @override
  bool build() {
    Future(() async {
      final v = await ref.read(databaseProvider).getSetting(proSettingKey);
      state = v == '1';
    });
    return false;
  }

  Future<void> grant() async {
    state = true;
    await ref.read(databaseProvider).setSetting(proSettingKey, '1');
  }
}

const proSettingKey = 'pro_entitled';

final proStatusProvider =
    NotifierProvider<ProStatus, bool>(ProStatus.new);


final billingProvider =
    Provider<BillingService>((ref) => throw UnimplementedError());

/// Drives purchase/restore against [BillingService]; grants entitlement on
/// verified purchases via the callback wired in main.
class ProPurchaseController {
  ProPurchaseController(this._billing);

  final BillingService _billing;
  bool _busy = false;

  Future<String?> buy(ProductDetails product) async {
    if (_busy) return 'pending';
    _busy = true;
    try {
      await _billing.buy(product);
      return null;
    } catch (_) {
      return 'error';
    } finally {
      _busy = false;
    }
  }

  Future<String?> restore() async {
    if (_busy) return 'pending';
    _busy = true;
    try {
      await _billing.restore();
      return null;
    } catch (_) {
      return 'error';
    } finally {
      _busy = false;
    }
  }
}

final proPurchaseControllerProvider =
    Provider<ProPurchaseController>((ref) {
  final controller = ProPurchaseController(ref.watch(billingProvider));
  ref.onDispose(() {});
  return controller;
});