import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';

import '../../../support/app_test_harness.dart';

void main() {
  late AppDatabase db;
  late DriftLoopsRepository repository;

  setUp(() {
    db = createInMemoryDb();
    repository = DriftLoopsRepository(db);
  });
  tearDown(() => db.close());

  group('notes (T10)', () {
    test('updateNote persists and clears with null', () async {
      final loop = await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
      );

      await repository.updateNote(loop.id, 'He wants v2 by Friday');
      expect(
        (await repository.getLoop(loop.id))!.commitment.note,
        'He wants v2 by Friday',
      );

      await repository.updateNote(loop.id, null);
      expect((await repository.getLoop(loop.id))!.commitment.note, isNull);
    });

    test('searchLoops matches titles and notes', () async {
      final a = await repository.createCommitment(
        title: 'Send revision to Budi',
        direction: Direction.outgoing,
      );
      final b = await repository.createCommitment(
        title: 'Renew license',
        direction: Direction.outgoing,
      );
      await repository.updateNote(b.id, 'portal login in notes app');

      final byTitle = await repository.searchLoops('revisi');
      expect(byTitle.single.commitment.id, a.id);

      final byNote = await repository.searchLoops('portal');
      expect(byNote.single.commitment.title, 'Renew license');
    });
  });

  group('search people (T10)', () {
    test('matches person names via the join', () async {
      final budi = await repository.findOrCreatePerson('Budi Santoso');
      await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
        personId: budi.id,
      );

      final results = await repository.searchLoops('budi');
      expect(results.single.person?.name, 'Budi Santoso');
    });
  });

  group('samples (T09)', () {
    test('sampleLoops lists flagged rows and removeAllSamples clears them',
        () async {
      await db.into(db.commitments).insert(
            CommitmentsCompanion.insert(
              title: 'Sample one',
              direction: Direction.incoming,
              status: CommitmentStatus.open,
              sample: const Value(true),
            ),
          );
      await repository.createCommitment(
        title: 'Real loop',
        direction: Direction.outgoing,
      );

      expect((await repository.sampleLoops()).single.title, 'Sample one');

      await repository.removeAllSamples();

      expect(await repository.sampleLoops(), isEmpty);
      final open = await repository.watchOpenLoops().first;
      expect(open.single.commitment.title, 'Real loop');
    });
  });
}