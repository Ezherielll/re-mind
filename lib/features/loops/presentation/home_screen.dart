import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Home screen: the single prioritized open-loop list (page spec:
/// design-system/re-mind/pages/home.md). T01 delivers the themed shell with
/// the empty state; grouping and rows arrive with T02+.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final display = TextStyle(
      inherit: false,
      fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      color: Theme.of(context).colorScheme.onSurface,
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(l10n.homeTitle, style: display),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('0', style: display.copyWith(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homeEmptyTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: Text(l10n.homeEmptyCta),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: Text(l10n.homeCaptureLabel),
      ),
    );
  }
}
