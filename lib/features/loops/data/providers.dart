import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/providers.dart';
import '../../../core/db/app_database.dart';
import 'loops_repository.dart';

final loopsRepositoryProvider = Provider<LoopsRepository>(
  (ref) => DriftLoopsRepository(ref.watch(databaseProvider)),
);

final openLoopsProvider = StreamProvider(
  (ref) => ref.watch(loopsRepositoryProvider).watchOpenLoops(),
);

/// Sample loops still present (T09 banner).
final samplesProvider = FutureProvider<List<Commitment>>(
  (ref) => ref.watch(loopsRepositoryProvider).sampleLoops(),
);