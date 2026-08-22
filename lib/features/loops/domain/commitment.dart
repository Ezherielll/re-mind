/// Domain vocabulary for open loops — see CONTEXT.md.
///
/// These enums are stored as text via Drift's `textEnum` so the database
/// content stays human-readable and migration-friendly.
enum Direction { outgoing, incoming }

enum CommitmentStatus { open, done }

enum LoopEventType { created, followedUp, done }
