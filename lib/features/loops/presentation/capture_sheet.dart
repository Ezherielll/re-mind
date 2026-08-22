import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';
import '../../../l10n/app_localizations.dart';
import '../data/providers.dart';

/// Capture flow (page spec: design-system/re-mind/pages/capture.md).
///
/// T03 scope adds the optional person field with prefix suggestions.
/// Date chips arrive with T04.
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
  final _personController = TextEditingController();
  List<Person> _suggestions = const [];
  Direction _direction = Direction.outgoing;

  @override
  void dispose() {
    _titleController.dispose();
    _personController.dispose();
    super.dispose();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  Future<void> _searchPeople(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (mounted) setState(() => _suggestions = const []);
      return;
    }
    final results =
        await ref.read(loopsRepositoryProvider).searchPeople(trimmed);
    if (mounted) setState(() => _suggestions = results);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(loopsRepositoryProvider);

    final personName = _personController.text.trim();
    final personId = personName.isEmpty
        ? null
        : (await repository.findOrCreatePerson(personName)).id;

    await repository.createCommitment(
      title: title,
      direction: _direction,
      personId: personId,
    );
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
          const SizedBox(height: 16),
          TextField(
            controller: _personController,
            onChanged: _searchPeople,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
              hintText: l10n.capturePersonHint,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final person in _suggestions.take(4))
                    ActionChip(
                      key: ValueKey('suggest-${person.id}'),
                      label: Text(person.name),
                      onPressed: () {
                        _personController.text = person.name;
                        setState(() => _suggestions = const []);
                      },
                    ),
                ],
              ),
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
