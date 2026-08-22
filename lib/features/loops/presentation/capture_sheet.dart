import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/commitment.dart';
import '../data/providers.dart';

/// Capture flow (page spec: design-system/re-mind/pages/capture.md).
///
/// T02 scope: text + direction toggle + save. Person linking arrives with
/// T03, date chips with T04.
class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CaptureSheet(),
    );
  }

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _titleController = TextEditingController();
  Direction _direction = Direction.outgoing;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(loopsRepositoryProvider)
        .createCommitment(title: title, direction: _direction);
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(l10n.saved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          TextField(
            autofocus: true,
            controller: _titleController,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.captureHint,
              label: Text(l10n.captureHint),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<Direction>(
            segments: [
              ButtonSegment(
                value: Direction.outgoing,
                label: Text(l10n.directionOutgoing),
              ),
              ButtonSegment(
                value: Direction.incoming,
                label: Text(l10n.directionIncoming),
              ),
            ],
            selected: {_direction},
            onSelectionChanged: (selection) =>
                setState(() => _direction = selection.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
