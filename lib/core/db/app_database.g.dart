// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CommitmentsTable extends Commitments
    with TableInfo<$CommitmentsTable, Commitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Direction, String> direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Direction>($CommitmentsTable.$converterdirection);
  @override
  late final GeneratedColumnWithTypeConverter<CommitmentStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CommitmentStatus>($CommitmentsTable.$converterstatus);
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followUpAtMeta = const VerificationMeta(
    'followUpAt',
  );
  @override
  late final GeneratedColumn<DateTime> followUpAt = GeneratedColumn<DateTime>(
    'follow_up_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    direction,
    status,
    dueDate,
    followUpAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Commitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('follow_up_at')) {
      context.handle(
        _followUpAtMeta,
        followUpAt.isAcceptableOrUnknown(
          data['follow_up_at']!,
          _followUpAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      direction: $CommitmentsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      status: $CommitmentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      followUpAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}follow_up_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CommitmentsTable createAlias(String alias) {
    return $CommitmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Direction, String, String> $converterdirection =
      const EnumNameConverter<Direction>(Direction.values);
  static JsonTypeConverter2<CommitmentStatus, String, String> $converterstatus =
      const EnumNameConverter<CommitmentStatus>(CommitmentStatus.values);
}

class Commitment extends DataClass implements Insertable<Commitment> {
  final int id;
  final String title;
  final Direction direction;
  final CommitmentStatus status;
  final DateTime? dueDate;
  final DateTime? followUpAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Commitment({
    required this.id,
    required this.title,
    required this.direction,
    required this.status,
    this.dueDate,
    this.followUpAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['direction'] = Variable<String>(
        $CommitmentsTable.$converterdirection.toSql(direction),
      );
    }
    {
      map['status'] = Variable<String>(
        $CommitmentsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || followUpAt != null) {
      map['follow_up_at'] = Variable<DateTime>(followUpAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CommitmentsCompanion toCompanion(bool nullToAbsent) {
    return CommitmentsCompanion(
      id: Value(id),
      title: Value(title),
      direction: Value(direction),
      status: Value(status),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      followUpAt: followUpAt == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Commitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commitment(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      direction: $CommitmentsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      status: $CommitmentsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      followUpAt: serializer.fromJson<DateTime?>(json['followUpAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'direction': serializer.toJson<String>(
        $CommitmentsTable.$converterdirection.toJson(direction),
      ),
      'status': serializer.toJson<String>(
        $CommitmentsTable.$converterstatus.toJson(status),
      ),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'followUpAt': serializer.toJson<DateTime?>(followUpAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Commitment copyWith({
    int? id,
    String? title,
    Direction? direction,
    CommitmentStatus? status,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<DateTime?> followUpAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Commitment(
    id: id ?? this.id,
    title: title ?? this.title,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    followUpAt: followUpAt.present ? followUpAt.value : this.followUpAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Commitment copyWithCompanion(CommitmentsCompanion data) {
    return Commitment(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      followUpAt: data.followUpAt.present
          ? data.followUpAt.value
          : this.followUpAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commitment(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('followUpAt: $followUpAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    direction,
    status,
    dueDate,
    followUpAt,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commitment &&
          other.id == this.id &&
          other.title == this.title &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.dueDate == this.dueDate &&
          other.followUpAt == this.followUpAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CommitmentsCompanion extends UpdateCompanion<Commitment> {
  final Value<int> id;
  final Value<String> title;
  final Value<Direction> direction;
  final Value<CommitmentStatus> status;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> followUpAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const CommitmentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.followUpAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CommitmentsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required Direction direction,
    required CommitmentStatus status,
    this.dueDate = const Value.absent(),
    this.followUpAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : title = Value(title),
       direction = Value(direction),
       status = Value(status);
  static Insertable<Commitment> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? followUpAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (dueDate != null) 'due_date': dueDate,
      if (followUpAt != null) 'follow_up_at': followUpAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  CommitmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<Direction>? direction,
    Value<CommitmentStatus>? status,
    Value<DateTime?>? dueDate,
    Value<DateTime?>? followUpAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return CommitmentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      followUpAt: followUpAt ?? this.followUpAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $CommitmentsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CommitmentsTable.$converterstatus.toSql(status.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (followUpAt.present) {
      map['follow_up_at'] = Variable<DateTime>(followUpAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('dueDate: $dueDate, ')
          ..write('followUpAt: $followUpAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $LoopEventsTable extends LoopEvents
    with TableInfo<$LoopEventsTable, LoopEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoopEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _commitmentIdMeta = const VerificationMeta(
    'commitmentId',
  );
  @override
  late final GeneratedColumn<int> commitmentId = GeneratedColumn<int>(
    'commitment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES commitments (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LoopEventType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LoopEventType>($LoopEventsTable.$convertertype);
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, commitmentId, type, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loop_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoopEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('commitment_id')) {
      context.handle(
        _commitmentIdMeta,
        commitmentId.isAcceptableOrUnknown(
          data['commitment_id']!,
          _commitmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commitmentIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoopEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoopEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      commitmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commitment_id'],
      )!,
      type: $LoopEventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $LoopEventsTable createAlias(String alias) {
    return $LoopEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LoopEventType, String, String> $convertertype =
      const EnumNameConverter<LoopEventType>(LoopEventType.values);
}

class LoopEvent extends DataClass implements Insertable<LoopEvent> {
  final int id;
  final int commitmentId;
  final LoopEventType type;
  final DateTime occurredAt;
  const LoopEvent({
    required this.id,
    required this.commitmentId,
    required this.type,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['commitment_id'] = Variable<int>(commitmentId);
    {
      map['type'] = Variable<String>(
        $LoopEventsTable.$convertertype.toSql(type),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  LoopEventsCompanion toCompanion(bool nullToAbsent) {
    return LoopEventsCompanion(
      id: Value(id),
      commitmentId: Value(commitmentId),
      type: Value(type),
      occurredAt: Value(occurredAt),
    );
  }

  factory LoopEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoopEvent(
      id: serializer.fromJson<int>(json['id']),
      commitmentId: serializer.fromJson<int>(json['commitmentId']),
      type: $LoopEventsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'commitmentId': serializer.toJson<int>(commitmentId),
      'type': serializer.toJson<String>(
        $LoopEventsTable.$convertertype.toJson(type),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  LoopEvent copyWith({
    int? id,
    int? commitmentId,
    LoopEventType? type,
    DateTime? occurredAt,
  }) => LoopEvent(
    id: id ?? this.id,
    commitmentId: commitmentId ?? this.commitmentId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  LoopEvent copyWithCompanion(LoopEventsCompanion data) {
    return LoopEvent(
      id: data.id.present ? data.id.value : this.id,
      commitmentId: data.commitmentId.present
          ? data.commitmentId.value
          : this.commitmentId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoopEvent(')
          ..write('id: $id, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, commitmentId, type, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoopEvent &&
          other.id == this.id &&
          other.commitmentId == this.commitmentId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt);
}

class LoopEventsCompanion extends UpdateCompanion<LoopEvent> {
  final Value<int> id;
  final Value<int> commitmentId;
  final Value<LoopEventType> type;
  final Value<DateTime> occurredAt;
  const LoopEventsCompanion({
    this.id = const Value.absent(),
    this.commitmentId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  LoopEventsCompanion.insert({
    this.id = const Value.absent(),
    required int commitmentId,
    required LoopEventType type,
    this.occurredAt = const Value.absent(),
  }) : commitmentId = Value(commitmentId),
       type = Value(type);
  static Insertable<LoopEvent> custom({
    Expression<int>? id,
    Expression<int>? commitmentId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commitmentId != null) 'commitment_id': commitmentId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  LoopEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? commitmentId,
    Value<LoopEventType>? type,
    Value<DateTime>? occurredAt,
  }) {
    return LoopEventsCompanion(
      id: id ?? this.id,
      commitmentId: commitmentId ?? this.commitmentId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (commitmentId.present) {
      map['commitment_id'] = Variable<int>(commitmentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $LoopEventsTable.$convertertype.toSql(type.value),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoopEventsCompanion(')
          ..write('id: $id, ')
          ..write('commitmentId: $commitmentId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CommitmentsTable commitments = $CommitmentsTable(this);
  late final $LoopEventsTable loopEvents = $LoopEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [commitments, loopEvents];
}

typedef $$CommitmentsTableCreateCompanionBuilder =
    CommitmentsCompanion Function({
      Value<int> id,
      required String title,
      required Direction direction,
      required CommitmentStatus status,
      Value<DateTime?> dueDate,
      Value<DateTime?> followUpAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$CommitmentsTableUpdateCompanionBuilder =
    CommitmentsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<Direction> direction,
      Value<CommitmentStatus> status,
      Value<DateTime?> dueDate,
      Value<DateTime?> followUpAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$CommitmentsTableReferences
    extends BaseReferences<_$AppDatabase, $CommitmentsTable, Commitment> {
  $$CommitmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoopEventsTable, List<LoopEvent>>
  _loopEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loopEvents,
    aliasName: 'commitments__id__loop_events__commitment_id',
  );

  $$LoopEventsTableProcessedTableManager get loopEventsRefs {
    final manager = $$LoopEventsTableTableManager(
      $_db,
      $_db.loopEvents,
    ).filter((f) => f.commitmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loopEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CommitmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Direction, Direction, String> get direction =>
      $composableBuilder(
        column: $table.direction,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CommitmentStatus, CommitmentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> loopEventsRefs(
    Expression<bool> Function($$LoopEventsTableFilterComposer f) f,
  ) {
    final $$LoopEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loopEvents,
      getReferencedColumn: (t) => t.commitmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoopEventsTableFilterComposer(
            $db: $db,
            $table: $db.loopEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommitmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommitmentsTable> {
  $$CommitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Direction, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CommitmentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get followUpAt => $composableBuilder(
    column: $table.followUpAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> loopEventsRefs<T extends Object>(
    Expression<T> Function($$LoopEventsTableAnnotationComposer a) f,
  ) {
    final $$LoopEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loopEvents,
      getReferencedColumn: (t) => t.commitmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoopEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.loopEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CommitmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommitmentsTable,
          Commitment,
          $$CommitmentsTableFilterComposer,
          $$CommitmentsTableOrderingComposer,
          $$CommitmentsTableAnnotationComposer,
          $$CommitmentsTableCreateCompanionBuilder,
          $$CommitmentsTableUpdateCompanionBuilder,
          (Commitment, $$CommitmentsTableReferences),
          Commitment,
          PrefetchHooks Function({bool loopEventsRefs})
        > {
  $$CommitmentsTableTableManager(_$AppDatabase db, $CommitmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommitmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<Direction> direction = const Value.absent(),
                Value<CommitmentStatus> status = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> followUpAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CommitmentsCompanion(
                id: id,
                title: title,
                direction: direction,
                status: status,
                dueDate: dueDate,
                followUpAt: followUpAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required Direction direction,
                required CommitmentStatus status,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime?> followUpAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CommitmentsCompanion.insert(
                id: id,
                title: title,
                direction: direction,
                status: status,
                dueDate: dueDate,
                followUpAt: followUpAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loopEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (loopEventsRefs) db.loopEvents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (loopEventsRefs)
                    await $_getPrefetchedData<
                      Commitment,
                      $CommitmentsTable,
                      LoopEvent
                    >(
                      currentTable: table,
                      referencedTable: $$CommitmentsTableReferences
                          ._loopEventsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CommitmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).loopEventsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.commitmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CommitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommitmentsTable,
      Commitment,
      $$CommitmentsTableFilterComposer,
      $$CommitmentsTableOrderingComposer,
      $$CommitmentsTableAnnotationComposer,
      $$CommitmentsTableCreateCompanionBuilder,
      $$CommitmentsTableUpdateCompanionBuilder,
      (Commitment, $$CommitmentsTableReferences),
      Commitment,
      PrefetchHooks Function({bool loopEventsRefs})
    >;
typedef $$LoopEventsTableCreateCompanionBuilder =
    LoopEventsCompanion Function({
      Value<int> id,
      required int commitmentId,
      required LoopEventType type,
      Value<DateTime> occurredAt,
    });
typedef $$LoopEventsTableUpdateCompanionBuilder =
    LoopEventsCompanion Function({
      Value<int> id,
      Value<int> commitmentId,
      Value<LoopEventType> type,
      Value<DateTime> occurredAt,
    });

final class $$LoopEventsTableReferences
    extends BaseReferences<_$AppDatabase, $LoopEventsTable, LoopEvent> {
  $$LoopEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CommitmentsTable _commitmentIdTable(_$AppDatabase db) =>
      db.commitments.createAlias('loop_events__commitment_id__commitments__id');

  $$CommitmentsTableProcessedTableManager get commitmentId {
    final $_column = $_itemColumn<int>('commitment_id')!;

    final manager = $$CommitmentsTableTableManager(
      $_db,
      $_db.commitments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_commitmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoopEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LoopEventsTable> {
  $$LoopEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LoopEventType, LoopEventType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CommitmentsTableFilterComposer get commitmentId {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoopEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoopEventsTable> {
  $$LoopEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CommitmentsTableOrderingComposer get commitmentId {
    final $$CommitmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableOrderingComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoopEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoopEventsTable> {
  $$LoopEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoopEventType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$CommitmentsTableAnnotationComposer get commitmentId {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.commitmentId,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoopEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoopEventsTable,
          LoopEvent,
          $$LoopEventsTableFilterComposer,
          $$LoopEventsTableOrderingComposer,
          $$LoopEventsTableAnnotationComposer,
          $$LoopEventsTableCreateCompanionBuilder,
          $$LoopEventsTableUpdateCompanionBuilder,
          (LoopEvent, $$LoopEventsTableReferences),
          LoopEvent,
          PrefetchHooks Function({bool commitmentId})
        > {
  $$LoopEventsTableTableManager(_$AppDatabase db, $LoopEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoopEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoopEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoopEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> commitmentId = const Value.absent(),
                Value<LoopEventType> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => LoopEventsCompanion(
                id: id,
                commitmentId: commitmentId,
                type: type,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int commitmentId,
                required LoopEventType type,
                Value<DateTime> occurredAt = const Value.absent(),
              }) => LoopEventsCompanion.insert(
                id: id,
                commitmentId: commitmentId,
                type: type,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LoopEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({commitmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (commitmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.commitmentId,
                                referencedTable: $$LoopEventsTableReferences
                                    ._commitmentIdTable(db),
                                referencedColumn: $$LoopEventsTableReferences
                                    ._commitmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LoopEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoopEventsTable,
      LoopEvent,
      $$LoopEventsTableFilterComposer,
      $$LoopEventsTableOrderingComposer,
      $$LoopEventsTableAnnotationComposer,
      $$LoopEventsTableCreateCompanionBuilder,
      $$LoopEventsTableUpdateCompanionBuilder,
      (LoopEvent, $$LoopEventsTableReferences),
      LoopEvent,
      PrefetchHooks Function({bool commitmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CommitmentsTableTableManager get commitments =>
      $$CommitmentsTableTableManager(_db, _db.commitments);
  $$LoopEventsTableTableManager get loopEvents =>
      $$LoopEventsTableTableManager(_db, _db.loopEvents);
}
