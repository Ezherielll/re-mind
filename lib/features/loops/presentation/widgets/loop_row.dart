import 'package:flutter/material.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/domain/commitment.dart';
import '../../data/loops_repository.dart';

/// The one visual language for "a loop" (pages/home.md): reused by Home and
/// Person view. T03 scope: direction icon, title, optional person chip.
/// Urgency dot arrives with T05.
class LoopRow extends StatelessWidget {
  const LoopRow({
    super.key,
    required this.item,
    this.onTap,
    this.onTapPerson,
  });

  final LoopWithPerson item;
  final VoidCallback? onTap;
  final void Function(Person person)? onTapPerson;

  @override
  Widget build(BuildContext context) {
    final person = item.person;
    return ListTile(
      key: ValueKey(item.commitment.id),
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      leading: Icon(
        item.commitment.direction == Direction.outgoing
            ? Icons.north_east
            : Icons.south_west,
      ),
      title: Text(
        item.commitment.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: person == null
          ? null
          : InkWell(
              onTap: onTapPerson == null ? null : () => onTapPerson!(person),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      onTap: onTap,
    );
  }
}
