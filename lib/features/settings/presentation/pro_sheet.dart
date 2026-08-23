import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../l10n/app_localizations.dart';
import 'pro_status.dart';

/// Lifetime Pro purchase sheet (pages/settings.md Pro section).
class ProSheet extends ConsumerStatefulWidget {
  const ProSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const ProSheet(),
      );

  @override
  ConsumerState<ProSheet> createState() => _ProSheetState();
}

class _ProSheetState extends ConsumerState<ProSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _buy() async {
    final l10n = AppLocalizations.of(context);
    final billing = ref.read(billingProvider);
    final product = await billing.loadProduct();
    if (product == null) {
      setState(() => _error = l10n.proError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(proPurchaseControllerProvider).buy(product);
    if (!mounted) return;
    setState(() => _busy = false);
    // Grant arrives via the verified-purchase callback; optimistic UI only
    // closes on success launch.
    if (err != null) setState(() => _error = l10n.proError);
  }

  Future<void> _restore() async {
    final err = await ref.read(proPurchaseControllerProvider).restore();
    if (!mounted) return;
    if (err != null) setState(() => _error = err);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entitled = ref.watch(proStatusProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.proTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _benefit(context, Icons.palette_outlined, l10n.proBenefit1),
          _benefit(context, Icons.timeline, l10n.proBenefit2),
          _benefit(context, Icons.all_inclusive, l10n.proBenefit3),
          const SizedBox(height: 16),
          FutureBuilder<ProductDetails?>(
            future: ref.read(billingProvider).loadProduct(),
            builder: (context, snap) {
              final price = snap.data?.price ?? '\$6.99';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(price,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(l10n.proOneTime,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error)),
            ),
          entitled
              ? FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.proOwned))
              : _busy
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(onPressed: _buy, child: Text(l10n.proBuy)),
          TextButton(
            onPressed: entitled ? null : _restore,
            child: Text(l10n.proRestorePurchases),
          ),
        ],
      ),
    );
  }

  Widget _benefit(BuildContext context, IconData icon, String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      );
}
