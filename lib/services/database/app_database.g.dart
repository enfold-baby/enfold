// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BabiesTable extends Babies with TableInfo<$BabiesTable, Baby> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BabiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPreemieMeta = const VerificationMeta(
    'isPreemie',
  );
  @override
  late final GeneratedColumn<bool> isPreemie = GeneratedColumn<bool>(
    'is_preemie',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preemie" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverChildIdMeta = const VerificationMeta(
    'serverChildId',
  );
  @override
  late final GeneratedColumn<String> serverChildId = GeneratedColumn<String>(
    'server_child_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    isPreemie,
    createdAt,
    serverChildId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'babies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Baby> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('is_preemie')) {
      context.handle(
        _isPreemieMeta,
        isPreemie.isAcceptableOrUnknown(data['is_preemie']!, _isPreemieMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_child_id')) {
      context.handle(
        _serverChildIdMeta,
        serverChildId.isAcceptableOrUnknown(
          data['server_child_id']!,
          _serverChildIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Baby map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Baby(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      isPreemie: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preemie'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      serverChildId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_child_id'],
      ),
    );
  }

  @override
  $BabiesTable createAlias(String alias) {
    return $BabiesTable(attachedDatabase, alias);
  }
}

class Baby extends DataClass implements Insertable<Baby> {
  final String id;
  final String name;
  final DateTime? birthDate;
  final bool isPreemie;
  final DateTime createdAt;
  final String? serverChildId;
  const Baby({
    required this.id,
    required this.name,
    this.birthDate,
    required this.isPreemie,
    required this.createdAt,
    this.serverChildId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['is_preemie'] = Variable<bool>(isPreemie);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverChildId != null) {
      map['server_child_id'] = Variable<String>(serverChildId);
    }
    return map;
  }

  BabiesCompanion toCompanion(bool nullToAbsent) {
    return BabiesCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      isPreemie: Value(isPreemie),
      createdAt: Value(createdAt),
      serverChildId: serverChildId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverChildId),
    );
  }

  factory Baby.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Baby(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      isPreemie: serializer.fromJson<bool>(json['isPreemie']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverChildId: serializer.fromJson<String?>(json['serverChildId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'isPreemie': serializer.toJson<bool>(isPreemie),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverChildId': serializer.toJson<String?>(serverChildId),
    };
  }

  Baby copyWith({
    String? id,
    String? name,
    Value<DateTime?> birthDate = const Value.absent(),
    bool? isPreemie,
    DateTime? createdAt,
    Value<String?> serverChildId = const Value.absent(),
  }) => Baby(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    isPreemie: isPreemie ?? this.isPreemie,
    createdAt: createdAt ?? this.createdAt,
    serverChildId: serverChildId.present
        ? serverChildId.value
        : this.serverChildId,
  );
  Baby copyWithCompanion(BabiesCompanion data) {
    return Baby(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      isPreemie: data.isPreemie.present ? data.isPreemie.value : this.isPreemie,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverChildId: data.serverChildId.present
          ? data.serverChildId.value
          : this.serverChildId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Baby(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('isPreemie: $isPreemie, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverChildId: $serverChildId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, birthDate, isPreemie, createdAt, serverChildId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Baby &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.isPreemie == this.isPreemie &&
          other.createdAt == this.createdAt &&
          other.serverChildId == this.serverChildId);
}

class BabiesCompanion extends UpdateCompanion<Baby> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> birthDate;
  final Value<bool> isPreemie;
  final Value<DateTime> createdAt;
  final Value<String?> serverChildId;
  final Value<int> rowid;
  const BabiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.isPreemie = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverChildId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BabiesCompanion.insert({
    required String id,
    required String name,
    this.birthDate = const Value.absent(),
    this.isPreemie = const Value.absent(),
    required DateTime createdAt,
    this.serverChildId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Baby> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<bool>? isPreemie,
    Expression<DateTime>? createdAt,
    Expression<String>? serverChildId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (isPreemie != null) 'is_preemie': isPreemie,
      if (createdAt != null) 'created_at': createdAt,
      if (serverChildId != null) 'server_child_id': serverChildId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BabiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime?>? birthDate,
    Value<bool>? isPreemie,
    Value<DateTime>? createdAt,
    Value<String?>? serverChildId,
    Value<int>? rowid,
  }) {
    return BabiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      isPreemie: isPreemie ?? this.isPreemie,
      createdAt: createdAt ?? this.createdAt,
      serverChildId: serverChildId ?? this.serverChildId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (isPreemie.present) {
      map['is_preemie'] = Variable<bool>(isPreemie.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverChildId.present) {
      map['server_child_id'] = Variable<String>(serverChildId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BabiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('isPreemie: $isPreemie, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverChildId: $serverChildId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareEventsTable extends CareEvents
    with TableInfo<$CareEventsTable, CareEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<String> babyId = GeneratedColumn<String>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> clientUpdatedAt =
      GeneratedColumn<DateTime>(
        'client_updated_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _loggedByUserIdMeta = const VerificationMeta(
    'loggedByUserId',
  );
  @override
  late final GeneratedColumn<String> loggedByUserId = GeneratedColumn<String>(
    'logged_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedByDisplayNameMeta =
      const VerificationMeta('loggedByDisplayName');
  @override
  late final GeneratedColumn<String> loggedByDisplayName =
      GeneratedColumn<String>(
        'logged_by_display_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    type,
    occurredAt,
    detailsJson,
    note,
    clientUpdatedAt,
    pendingSync,
    deletedAt,
    loggedByUserId,
    loggedByDisplayName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientUpdatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('logged_by_user_id')) {
      context.handle(
        _loggedByUserIdMeta,
        loggedByUserId.isAcceptableOrUnknown(
          data['logged_by_user_id']!,
          _loggedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('logged_by_display_name')) {
      context.handle(
        _loggedByDisplayNameMeta,
        loggedByDisplayName.isAcceptableOrUnknown(
          data['logged_by_display_name']!,
          _loggedByDisplayNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baby_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      loggedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logged_by_user_id'],
      ),
      loggedByDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logged_by_display_name'],
      ),
    );
  }

  @override
  $CareEventsTable createAlias(String alias) {
    return $CareEventsTable(attachedDatabase, alias);
  }
}

class CareEvent extends DataClass implements Insertable<CareEvent> {
  final String id;
  final String babyId;
  final String type;
  final DateTime occurredAt;
  final String detailsJson;
  final String note;
  final DateTime clientUpdatedAt;
  final bool pendingSync;
  final DateTime? deletedAt;
  final String? loggedByUserId;
  final String? loggedByDisplayName;
  const CareEvent({
    required this.id,
    required this.babyId,
    required this.type,
    required this.occurredAt,
    required this.detailsJson,
    required this.note,
    required this.clientUpdatedAt,
    required this.pendingSync,
    this.deletedAt,
    this.loggedByUserId,
    this.loggedByDisplayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['baby_id'] = Variable<String>(babyId);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['details_json'] = Variable<String>(detailsJson);
    map['note'] = Variable<String>(note);
    map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || loggedByUserId != null) {
      map['logged_by_user_id'] = Variable<String>(loggedByUserId);
    }
    if (!nullToAbsent || loggedByDisplayName != null) {
      map['logged_by_display_name'] = Variable<String>(loggedByDisplayName);
    }
    return map;
  }

  CareEventsCompanion toCompanion(bool nullToAbsent) {
    return CareEventsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      type: Value(type),
      occurredAt: Value(occurredAt),
      detailsJson: Value(detailsJson),
      note: Value(note),
      clientUpdatedAt: Value(clientUpdatedAt),
      pendingSync: Value(pendingSync),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      loggedByUserId: loggedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(loggedByUserId),
      loggedByDisplayName: loggedByDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(loggedByDisplayName),
    );
  }

  factory CareEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareEvent(
      id: serializer.fromJson<String>(json['id']),
      babyId: serializer.fromJson<String>(json['babyId']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      note: serializer.fromJson<String>(json['note']),
      clientUpdatedAt: serializer.fromJson<DateTime>(json['clientUpdatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      loggedByUserId: serializer.fromJson<String?>(json['loggedByUserId']),
      loggedByDisplayName: serializer.fromJson<String?>(
        json['loggedByDisplayName'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'babyId': serializer.toJson<String>(babyId),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'note': serializer.toJson<String>(note),
      'clientUpdatedAt': serializer.toJson<DateTime>(clientUpdatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'loggedByUserId': serializer.toJson<String?>(loggedByUserId),
      'loggedByDisplayName': serializer.toJson<String?>(loggedByDisplayName),
    };
  }

  CareEvent copyWith({
    String? id,
    String? babyId,
    String? type,
    DateTime? occurredAt,
    String? detailsJson,
    String? note,
    DateTime? clientUpdatedAt,
    bool? pendingSync,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> loggedByUserId = const Value.absent(),
    Value<String?> loggedByDisplayName = const Value.absent(),
  }) => CareEvent(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    detailsJson: detailsJson ?? this.detailsJson,
    note: note ?? this.note,
    clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    loggedByUserId: loggedByUserId.present
        ? loggedByUserId.value
        : this.loggedByUserId,
    loggedByDisplayName: loggedByDisplayName.present
        ? loggedByDisplayName.value
        : this.loggedByDisplayName,
  );
  CareEvent copyWithCompanion(CareEventsCompanion data) {
    return CareEvent(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      note: data.note.present ? data.note.value : this.note,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      loggedByUserId: data.loggedByUserId.present
          ? data.loggedByUserId.value
          : this.loggedByUserId,
      loggedByDisplayName: data.loggedByDisplayName.present
          ? data.loggedByDisplayName.value
          : this.loggedByDisplayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareEvent(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('note: $note, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loggedByUserId: $loggedByUserId, ')
          ..write('loggedByDisplayName: $loggedByDisplayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    type,
    occurredAt,
    detailsJson,
    note,
    clientUpdatedAt,
    pendingSync,
    deletedAt,
    loggedByUserId,
    loggedByDisplayName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareEvent &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.detailsJson == this.detailsJson &&
          other.note == this.note &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.pendingSync == this.pendingSync &&
          other.deletedAt == this.deletedAt &&
          other.loggedByUserId == this.loggedByUserId &&
          other.loggedByDisplayName == this.loggedByDisplayName);
}

class CareEventsCompanion extends UpdateCompanion<CareEvent> {
  final Value<String> id;
  final Value<String> babyId;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String> detailsJson;
  final Value<String> note;
  final Value<DateTime> clientUpdatedAt;
  final Value<bool> pendingSync;
  final Value<DateTime?> deletedAt;
  final Value<String?> loggedByUserId;
  final Value<String?> loggedByDisplayName;
  final Value<int> rowid;
  const CareEventsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loggedByUserId = const Value.absent(),
    this.loggedByDisplayName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareEventsCompanion.insert({
    required String id,
    required String babyId,
    required String type,
    required DateTime occurredAt,
    this.detailsJson = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime clientUpdatedAt,
    this.pendingSync = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loggedByUserId = const Value.absent(),
    this.loggedByDisplayName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       babyId = Value(babyId),
       type = Value(type),
       occurredAt = Value(occurredAt),
       clientUpdatedAt = Value(clientUpdatedAt);
  static Insertable<CareEvent> custom({
    Expression<String>? id,
    Expression<String>? babyId,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? detailsJson,
    Expression<String>? note,
    Expression<DateTime>? clientUpdatedAt,
    Expression<bool>? pendingSync,
    Expression<DateTime>? deletedAt,
    Expression<String>? loggedByUserId,
    Expression<String>? loggedByDisplayName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (detailsJson != null) 'details_json': detailsJson,
      if (note != null) 'note': note,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (loggedByUserId != null) 'logged_by_user_id': loggedByUserId,
      if (loggedByDisplayName != null)
        'logged_by_display_name': loggedByDisplayName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? babyId,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String>? detailsJson,
    Value<String>? note,
    Value<DateTime>? clientUpdatedAt,
    Value<bool>? pendingSync,
    Value<DateTime?>? deletedAt,
    Value<String?>? loggedByUserId,
    Value<String?>? loggedByDisplayName,
    Value<int>? rowid,
  }) {
    return CareEventsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      detailsJson: detailsJson ?? this.detailsJson,
      note: note ?? this.note,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      deletedAt: deletedAt ?? this.deletedAt,
      loggedByUserId: loggedByUserId ?? this.loggedByUserId,
      loggedByDisplayName: loggedByDisplayName ?? this.loggedByDisplayName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<String>(babyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<DateTime>(clientUpdatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (loggedByUserId.present) {
      map['logged_by_user_id'] = Variable<String>(loggedByUserId.value);
    }
    if (loggedByDisplayName.present) {
      map['logged_by_display_name'] = Variable<String>(
        loggedByDisplayName.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareEventsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('note: $note, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loggedByUserId: $loggedByUserId, ')
          ..write('loggedByDisplayName: $loggedByDisplayName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PregnancyProfilesTable extends PregnancyProfiles
    with TableInfo<$PregnancyProfilesTable, PregnancyProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnancyProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _kickCountTodayMeta = const VerificationMeta(
    'kickCountToday',
  );
  @override
  late final GeneratedColumn<int> kickCountToday = GeneratedColumn<int>(
    'kick_count_today',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kickCountDateMeta = const VerificationMeta(
    'kickCountDate',
  );
  @override
  late final GeneratedColumn<DateTime> kickCountDate =
      GeneratedColumn<DateTime>(
        'kick_count_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dueDate,
    kickCountToday,
    kickCountDate,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancy_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<PregnancyProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('kick_count_today')) {
      context.handle(
        _kickCountTodayMeta,
        kickCountToday.isAcceptableOrUnknown(
          data['kick_count_today']!,
          _kickCountTodayMeta,
        ),
      );
    }
    if (data.containsKey('kick_count_date')) {
      context.handle(
        _kickCountDateMeta,
        kickCountDate.isAcceptableOrUnknown(
          data['kick_count_date']!,
          _kickCountDateMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PregnancyProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PregnancyProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      kickCountToday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kick_count_today'],
      )!,
      kickCountDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}kick_count_date'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PregnancyProfilesTable createAlias(String alias) {
    return $PregnancyProfilesTable(attachedDatabase, alias);
  }
}

class PregnancyProfile extends DataClass
    implements Insertable<PregnancyProfile> {
  final String id;
  final DateTime? dueDate;
  final int kickCountToday;
  final DateTime? kickCountDate;
  final DateTime updatedAt;
  const PregnancyProfile({
    required this.id,
    this.dueDate,
    required this.kickCountToday,
    this.kickCountDate,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['kick_count_today'] = Variable<int>(kickCountToday);
    if (!nullToAbsent || kickCountDate != null) {
      map['kick_count_date'] = Variable<DateTime>(kickCountDate);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PregnancyProfilesCompanion toCompanion(bool nullToAbsent) {
    return PregnancyProfilesCompanion(
      id: Value(id),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      kickCountToday: Value(kickCountToday),
      kickCountDate: kickCountDate == null && nullToAbsent
          ? const Value.absent()
          : Value(kickCountDate),
      updatedAt: Value(updatedAt),
    );
  }

  factory PregnancyProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PregnancyProfile(
      id: serializer.fromJson<String>(json['id']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      kickCountToday: serializer.fromJson<int>(json['kickCountToday']),
      kickCountDate: serializer.fromJson<DateTime?>(json['kickCountDate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'kickCountToday': serializer.toJson<int>(kickCountToday),
      'kickCountDate': serializer.toJson<DateTime?>(kickCountDate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PregnancyProfile copyWith({
    String? id,
    Value<DateTime?> dueDate = const Value.absent(),
    int? kickCountToday,
    Value<DateTime?> kickCountDate = const Value.absent(),
    DateTime? updatedAt,
  }) => PregnancyProfile(
    id: id ?? this.id,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    kickCountToday: kickCountToday ?? this.kickCountToday,
    kickCountDate: kickCountDate.present
        ? kickCountDate.value
        : this.kickCountDate,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PregnancyProfile copyWithCompanion(PregnancyProfilesCompanion data) {
    return PregnancyProfile(
      id: data.id.present ? data.id.value : this.id,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      kickCountToday: data.kickCountToday.present
          ? data.kickCountToday.value
          : this.kickCountToday,
      kickCountDate: data.kickCountDate.present
          ? data.kickCountDate.value
          : this.kickCountDate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyProfile(')
          ..write('id: $id, ')
          ..write('dueDate: $dueDate, ')
          ..write('kickCountToday: $kickCountToday, ')
          ..write('kickCountDate: $kickCountDate, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dueDate, kickCountToday, kickCountDate, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PregnancyProfile &&
          other.id == this.id &&
          other.dueDate == this.dueDate &&
          other.kickCountToday == this.kickCountToday &&
          other.kickCountDate == this.kickCountDate &&
          other.updatedAt == this.updatedAt);
}

class PregnancyProfilesCompanion extends UpdateCompanion<PregnancyProfile> {
  final Value<String> id;
  final Value<DateTime?> dueDate;
  final Value<int> kickCountToday;
  final Value<DateTime?> kickCountDate;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PregnancyProfilesCompanion({
    this.id = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.kickCountToday = const Value.absent(),
    this.kickCountDate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PregnancyProfilesCompanion.insert({
    required String id,
    this.dueDate = const Value.absent(),
    this.kickCountToday = const Value.absent(),
    this.kickCountDate = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<PregnancyProfile> custom({
    Expression<String>? id,
    Expression<DateTime>? dueDate,
    Expression<int>? kickCountToday,
    Expression<DateTime>? kickCountDate,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dueDate != null) 'due_date': dueDate,
      if (kickCountToday != null) 'kick_count_today': kickCountToday,
      if (kickCountDate != null) 'kick_count_date': kickCountDate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PregnancyProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime?>? dueDate,
    Value<int>? kickCountToday,
    Value<DateTime?>? kickCountDate,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PregnancyProfilesCompanion(
      id: id ?? this.id,
      dueDate: dueDate ?? this.dueDate,
      kickCountToday: kickCountToday ?? this.kickCountToday,
      kickCountDate: kickCountDate ?? this.kickCountDate,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (kickCountToday.present) {
      map['kick_count_today'] = Variable<int>(kickCountToday.value);
    }
    if (kickCountDate.present) {
      map['kick_count_date'] = Variable<DateTime>(kickCountDate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyProfilesCompanion(')
          ..write('id: $id, ')
          ..write('dueDate: $dueDate, ')
          ..write('kickCountToday: $kickCountToday, ')
          ..write('kickCountDate: $kickCountDate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PregnancyAppointmentsTable extends PregnancyAppointments
    with TableInfo<$PregnancyAppointmentsTable, PregnancyAppointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnancyAppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    scheduledAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancy_appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PregnancyAppointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PregnancyAppointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PregnancyAppointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PregnancyAppointmentsTable createAlias(String alias) {
    return $PregnancyAppointmentsTable(attachedDatabase, alias);
  }
}

class PregnancyAppointment extends DataClass
    implements Insertable<PregnancyAppointment> {
  final String id;
  final String title;
  final DateTime? scheduledAt;
  final String notes;
  final DateTime createdAt;
  const PregnancyAppointment({
    required this.id,
    required this.title,
    this.scheduledAt,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PregnancyAppointmentsCompanion toCompanion(bool nullToAbsent) {
    return PregnancyAppointmentsCompanion(
      id: Value(id),
      title: Value(title),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory PregnancyAppointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PregnancyAppointment(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PregnancyAppointment copyWith({
    String? id,
    String? title,
    Value<DateTime?> scheduledAt = const Value.absent(),
    String? notes,
    DateTime? createdAt,
  }) => PregnancyAppointment(
    id: id ?? this.id,
    title: title ?? this.title,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  PregnancyAppointment copyWithCompanion(PregnancyAppointmentsCompanion data) {
    return PregnancyAppointment(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyAppointment(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, scheduledAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PregnancyAppointment &&
          other.id == this.id &&
          other.title == this.title &&
          other.scheduledAt == this.scheduledAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class PregnancyAppointmentsCompanion
    extends UpdateCompanion<PregnancyAppointment> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime?> scheduledAt;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PregnancyAppointmentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PregnancyAppointmentsCompanion.insert({
    required String id,
    required String title,
    this.scheduledAt = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<PregnancyAppointment> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? scheduledAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PregnancyAppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime?>? scheduledAt,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PregnancyAppointmentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PregnancyAppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _useImperialUnitsMeta = const VerificationMeta(
    'useImperialUnits',
  );
  @override
  late final GeneratedColumn<bool> useImperialUnits = GeneratedColumn<bool>(
    'use_imperial_units',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_imperial_units" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _partnerActivityPushEnabledMeta =
      const VerificationMeta('partnerActivityPushEnabled');
  @override
  late final GeneratedColumn<bool> partnerActivityPushEnabled =
      GeneratedColumn<bool>(
        'partner_activity_push_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("partner_activity_push_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _partnerGentleNudgeEnabledMeta =
      const VerificationMeta('partnerGentleNudgeEnabled');
  @override
  late final GeneratedColumn<bool> partnerGentleNudgeEnabled =
      GeneratedColumn<bool>(
        'partner_gentle_nudge_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("partner_gentle_nudge_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _lastSignedInUserIdMeta =
      const VerificationMeta('lastSignedInUserId');
  @override
  late final GeneratedColumn<String> lastSignedInUserId =
      GeneratedColumn<String>(
        'last_signed_in_user_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    onboardingCompleted,
    useImperialUnits,
    partnerActivityPushEnabled,
    partnerGentleNudgeEnabled,
    themeMode,
    lastSignedInUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('use_imperial_units')) {
      context.handle(
        _useImperialUnitsMeta,
        useImperialUnits.isAcceptableOrUnknown(
          data['use_imperial_units']!,
          _useImperialUnitsMeta,
        ),
      );
    }
    if (data.containsKey('partner_activity_push_enabled')) {
      context.handle(
        _partnerActivityPushEnabledMeta,
        partnerActivityPushEnabled.isAcceptableOrUnknown(
          data['partner_activity_push_enabled']!,
          _partnerActivityPushEnabledMeta,
        ),
      );
    }
    if (data.containsKey('partner_gentle_nudge_enabled')) {
      context.handle(
        _partnerGentleNudgeEnabledMeta,
        partnerGentleNudgeEnabled.isAcceptableOrUnknown(
          data['partner_gentle_nudge_enabled']!,
          _partnerGentleNudgeEnabledMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('last_signed_in_user_id')) {
      context.handle(
        _lastSignedInUserIdMeta,
        lastSignedInUserId.isAcceptableOrUnknown(
          data['last_signed_in_user_id']!,
          _lastSignedInUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      useImperialUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_imperial_units'],
      )!,
      partnerActivityPushEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}partner_activity_push_enabled'],
      )!,
      partnerGentleNudgeEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}partner_gentle_nudge_enabled'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      lastSignedInUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_signed_in_user_id'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool onboardingCompleted;
  final bool useImperialUnits;
  final bool partnerActivityPushEnabled;
  final bool partnerGentleNudgeEnabled;
  final String themeMode;

  /// Last account that successfully signed in on this install (for switch isolation).
  final String? lastSignedInUserId;
  const AppSetting({
    required this.id,
    required this.onboardingCompleted,
    required this.useImperialUnits,
    required this.partnerActivityPushEnabled,
    required this.partnerGentleNudgeEnabled,
    required this.themeMode,
    this.lastSignedInUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['use_imperial_units'] = Variable<bool>(useImperialUnits);
    map['partner_activity_push_enabled'] = Variable<bool>(
      partnerActivityPushEnabled,
    );
    map['partner_gentle_nudge_enabled'] = Variable<bool>(
      partnerGentleNudgeEnabled,
    );
    map['theme_mode'] = Variable<String>(themeMode);
    if (!nullToAbsent || lastSignedInUserId != null) {
      map['last_signed_in_user_id'] = Variable<String>(lastSignedInUserId);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      onboardingCompleted: Value(onboardingCompleted),
      useImperialUnits: Value(useImperialUnits),
      partnerActivityPushEnabled: Value(partnerActivityPushEnabled),
      partnerGentleNudgeEnabled: Value(partnerGentleNudgeEnabled),
      themeMode: Value(themeMode),
      lastSignedInUserId: lastSignedInUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSignedInUserId),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      useImperialUnits: serializer.fromJson<bool>(json['useImperialUnits']),
      partnerActivityPushEnabled: serializer.fromJson<bool>(
        json['partnerActivityPushEnabled'],
      ),
      partnerGentleNudgeEnabled: serializer.fromJson<bool>(
        json['partnerGentleNudgeEnabled'],
      ),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      lastSignedInUserId: serializer.fromJson<String?>(
        json['lastSignedInUserId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'useImperialUnits': serializer.toJson<bool>(useImperialUnits),
      'partnerActivityPushEnabled': serializer.toJson<bool>(
        partnerActivityPushEnabled,
      ),
      'partnerGentleNudgeEnabled': serializer.toJson<bool>(
        partnerGentleNudgeEnabled,
      ),
      'themeMode': serializer.toJson<String>(themeMode),
      'lastSignedInUserId': serializer.toJson<String?>(lastSignedInUserId),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? onboardingCompleted,
    bool? useImperialUnits,
    bool? partnerActivityPushEnabled,
    bool? partnerGentleNudgeEnabled,
    String? themeMode,
    Value<String?> lastSignedInUserId = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    useImperialUnits: useImperialUnits ?? this.useImperialUnits,
    partnerActivityPushEnabled:
        partnerActivityPushEnabled ?? this.partnerActivityPushEnabled,
    partnerGentleNudgeEnabled:
        partnerGentleNudgeEnabled ?? this.partnerGentleNudgeEnabled,
    themeMode: themeMode ?? this.themeMode,
    lastSignedInUserId: lastSignedInUserId.present
        ? lastSignedInUserId.value
        : this.lastSignedInUserId,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      useImperialUnits: data.useImperialUnits.present
          ? data.useImperialUnits.value
          : this.useImperialUnits,
      partnerActivityPushEnabled: data.partnerActivityPushEnabled.present
          ? data.partnerActivityPushEnabled.value
          : this.partnerActivityPushEnabled,
      partnerGentleNudgeEnabled: data.partnerGentleNudgeEnabled.present
          ? data.partnerGentleNudgeEnabled.value
          : this.partnerGentleNudgeEnabled,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      lastSignedInUserId: data.lastSignedInUserId.present
          ? data.lastSignedInUserId.value
          : this.lastSignedInUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('useImperialUnits: $useImperialUnits, ')
          ..write('partnerActivityPushEnabled: $partnerActivityPushEnabled, ')
          ..write('partnerGentleNudgeEnabled: $partnerGentleNudgeEnabled, ')
          ..write('themeMode: $themeMode, ')
          ..write('lastSignedInUserId: $lastSignedInUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    onboardingCompleted,
    useImperialUnits,
    partnerActivityPushEnabled,
    partnerGentleNudgeEnabled,
    themeMode,
    lastSignedInUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.useImperialUnits == this.useImperialUnits &&
          other.partnerActivityPushEnabled == this.partnerActivityPushEnabled &&
          other.partnerGentleNudgeEnabled == this.partnerGentleNudgeEnabled &&
          other.themeMode == this.themeMode &&
          other.lastSignedInUserId == this.lastSignedInUserId);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> onboardingCompleted;
  final Value<bool> useImperialUnits;
  final Value<bool> partnerActivityPushEnabled;
  final Value<bool> partnerGentleNudgeEnabled;
  final Value<String> themeMode;
  final Value<String?> lastSignedInUserId;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.useImperialUnits = const Value.absent(),
    this.partnerActivityPushEnabled = const Value.absent(),
    this.partnerGentleNudgeEnabled = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.lastSignedInUserId = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.useImperialUnits = const Value.absent(),
    this.partnerActivityPushEnabled = const Value.absent(),
    this.partnerGentleNudgeEnabled = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.lastSignedInUserId = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? onboardingCompleted,
    Expression<bool>? useImperialUnits,
    Expression<bool>? partnerActivityPushEnabled,
    Expression<bool>? partnerGentleNudgeEnabled,
    Expression<String>? themeMode,
    Expression<String>? lastSignedInUserId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (useImperialUnits != null) 'use_imperial_units': useImperialUnits,
      if (partnerActivityPushEnabled != null)
        'partner_activity_push_enabled': partnerActivityPushEnabled,
      if (partnerGentleNudgeEnabled != null)
        'partner_gentle_nudge_enabled': partnerGentleNudgeEnabled,
      if (themeMode != null) 'theme_mode': themeMode,
      if (lastSignedInUserId != null)
        'last_signed_in_user_id': lastSignedInUserId,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? onboardingCompleted,
    Value<bool>? useImperialUnits,
    Value<bool>? partnerActivityPushEnabled,
    Value<bool>? partnerGentleNudgeEnabled,
    Value<String>? themeMode,
    Value<String?>? lastSignedInUserId,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      useImperialUnits: useImperialUnits ?? this.useImperialUnits,
      partnerActivityPushEnabled:
          partnerActivityPushEnabled ?? this.partnerActivityPushEnabled,
      partnerGentleNudgeEnabled:
          partnerGentleNudgeEnabled ?? this.partnerGentleNudgeEnabled,
      themeMode: themeMode ?? this.themeMode,
      lastSignedInUserId: lastSignedInUserId ?? this.lastSignedInUserId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (useImperialUnits.present) {
      map['use_imperial_units'] = Variable<bool>(useImperialUnits.value);
    }
    if (partnerActivityPushEnabled.present) {
      map['partner_activity_push_enabled'] = Variable<bool>(
        partnerActivityPushEnabled.value,
      );
    }
    if (partnerGentleNudgeEnabled.present) {
      map['partner_gentle_nudge_enabled'] = Variable<bool>(
        partnerGentleNudgeEnabled.value,
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (lastSignedInUserId.present) {
      map['last_signed_in_user_id'] = Variable<String>(
        lastSignedInUserId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('useImperialUnits: $useImperialUnits, ')
          ..write('partnerActivityPushEnabled: $partnerActivityPushEnabled, ')
          ..write('partnerGentleNudgeEnabled: $partnerGentleNudgeEnabled, ')
          ..write('themeMode: $themeMode, ')
          ..write('lastSignedInUserId: $lastSignedInUserId')
          ..write(')'))
        .toString();
  }
}

class $GrowthMeasurementsTable extends GrowthMeasurements
    with TableInfo<$GrowthMeasurementsTable, GrowthMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrowthMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<String> babyId = GeneratedColumn<String>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta(
    'lengthCm',
  );
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headCmMeta = const VerificationMeta('headCm');
  @override
  late final GeneratedColumn<double> headCm = GeneratedColumn<double>(
    'head_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    babyId,
    measuredAt,
    weightKg,
    lengthCm,
    headCm,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'growth_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrowthMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    }
    if (data.containsKey('head_cm')) {
      context.handle(
        _headCmMeta,
        headCm.isAcceptableOrUnknown(data['head_cm']!, _headCmMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrowthMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrowthMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baby_id'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      ),
      headCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}head_cm'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GrowthMeasurementsTable createAlias(String alias) {
    return $GrowthMeasurementsTable(attachedDatabase, alias);
  }
}

class GrowthMeasurement extends DataClass
    implements Insertable<GrowthMeasurement> {
  final String id;
  final String babyId;
  final DateTime measuredAt;
  final double? weightKg;
  final double? lengthCm;
  final double? headCm;
  final String note;
  final DateTime createdAt;
  const GrowthMeasurement({
    required this.id,
    required this.babyId,
    required this.measuredAt,
    this.weightKg,
    this.lengthCm,
    this.headCm,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['baby_id'] = Variable<String>(babyId);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || lengthCm != null) {
      map['length_cm'] = Variable<double>(lengthCm);
    }
    if (!nullToAbsent || headCm != null) {
      map['head_cm'] = Variable<double>(headCm);
    }
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GrowthMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return GrowthMeasurementsCompanion(
      id: Value(id),
      babyId: Value(babyId),
      measuredAt: Value(measuredAt),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      lengthCm: lengthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthCm),
      headCm: headCm == null && nullToAbsent
          ? const Value.absent()
          : Value(headCm),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory GrowthMeasurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrowthMeasurement(
      id: serializer.fromJson<String>(json['id']),
      babyId: serializer.fromJson<String>(json['babyId']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      lengthCm: serializer.fromJson<double?>(json['lengthCm']),
      headCm: serializer.fromJson<double?>(json['headCm']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'babyId': serializer.toJson<String>(babyId),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'weightKg': serializer.toJson<double?>(weightKg),
      'lengthCm': serializer.toJson<double?>(lengthCm),
      'headCm': serializer.toJson<double?>(headCm),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GrowthMeasurement copyWith({
    String? id,
    String? babyId,
    DateTime? measuredAt,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> lengthCm = const Value.absent(),
    Value<double?> headCm = const Value.absent(),
    String? note,
    DateTime? createdAt,
  }) => GrowthMeasurement(
    id: id ?? this.id,
    babyId: babyId ?? this.babyId,
    measuredAt: measuredAt ?? this.measuredAt,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    lengthCm: lengthCm.present ? lengthCm.value : this.lengthCm,
    headCm: headCm.present ? headCm.value : this.headCm,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  GrowthMeasurement copyWithCompanion(GrowthMeasurementsCompanion data) {
    return GrowthMeasurement(
      id: data.id.present ? data.id.value : this.id,
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      headCm: data.headCm.present ? data.headCm.value : this.headCm,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrowthMeasurement(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('headCm: $headCm, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    babyId,
    measuredAt,
    weightKg,
    lengthCm,
    headCm,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrowthMeasurement &&
          other.id == this.id &&
          other.babyId == this.babyId &&
          other.measuredAt == this.measuredAt &&
          other.weightKg == this.weightKg &&
          other.lengthCm == this.lengthCm &&
          other.headCm == this.headCm &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class GrowthMeasurementsCompanion extends UpdateCompanion<GrowthMeasurement> {
  final Value<String> id;
  final Value<String> babyId;
  final Value<DateTime> measuredAt;
  final Value<double?> weightKg;
  final Value<double?> lengthCm;
  final Value<double?> headCm;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GrowthMeasurementsCompanion({
    this.id = const Value.absent(),
    this.babyId = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.headCm = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrowthMeasurementsCompanion.insert({
    required String id,
    required String babyId,
    required DateTime measuredAt,
    this.weightKg = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.headCm = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       babyId = Value(babyId),
       measuredAt = Value(measuredAt),
       createdAt = Value(createdAt);
  static Insertable<GrowthMeasurement> custom({
    Expression<String>? id,
    Expression<String>? babyId,
    Expression<DateTime>? measuredAt,
    Expression<double>? weightKg,
    Expression<double>? lengthCm,
    Expression<double>? headCm,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (babyId != null) 'baby_id': babyId,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (headCm != null) 'head_cm': headCm,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrowthMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String>? babyId,
    Value<DateTime>? measuredAt,
    Value<double?>? weightKg,
    Value<double?>? lengthCm,
    Value<double?>? headCm,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GrowthMeasurementsCompanion(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      lengthCm: lengthCm ?? this.lengthCm,
      headCm: headCm ?? this.headCm,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (babyId.present) {
      map['baby_id'] = Variable<String>(babyId.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (headCm.present) {
      map['head_cm'] = Variable<double>(headCm.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrowthMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('babyId: $babyId, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('headCm: $headCm, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestoneAchievementsTable extends MilestoneAchievements
    with TableInfo<$MilestoneAchievementsTable, MilestoneAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestoneAchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _babyIdMeta = const VerificationMeta('babyId');
  @override
  late final GeneratedColumn<String> babyId = GeneratedColumn<String>(
    'baby_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _milestoneKeyMeta = const VerificationMeta(
    'milestoneKey',
  );
  @override
  late final GeneratedColumn<String> milestoneKey = GeneratedColumn<String>(
    'milestone_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    babyId,
    milestoneKey,
    achievedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestone_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilestoneAchievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('baby_id')) {
      context.handle(
        _babyIdMeta,
        babyId.isAcceptableOrUnknown(data['baby_id']!, _babyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_babyIdMeta);
    }
    if (data.containsKey('milestone_key')) {
      context.handle(
        _milestoneKeyMeta,
        milestoneKey.isAcceptableOrUnknown(
          data['milestone_key']!,
          _milestoneKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneKeyMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {babyId, milestoneKey};
  @override
  MilestoneAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneAchievement(
      babyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baby_id'],
      )!,
      milestoneKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestone_key'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $MilestoneAchievementsTable createAlias(String alias) {
    return $MilestoneAchievementsTable(attachedDatabase, alias);
  }
}

class MilestoneAchievement extends DataClass
    implements Insertable<MilestoneAchievement> {
  final String babyId;
  final String milestoneKey;
  final DateTime achievedAt;
  final String note;
  const MilestoneAchievement({
    required this.babyId,
    required this.milestoneKey,
    required this.achievedAt,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['baby_id'] = Variable<String>(babyId);
    map['milestone_key'] = Variable<String>(milestoneKey);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    map['note'] = Variable<String>(note);
    return map;
  }

  MilestoneAchievementsCompanion toCompanion(bool nullToAbsent) {
    return MilestoneAchievementsCompanion(
      babyId: Value(babyId),
      milestoneKey: Value(milestoneKey),
      achievedAt: Value(achievedAt),
      note: Value(note),
    );
  }

  factory MilestoneAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneAchievement(
      babyId: serializer.fromJson<String>(json['babyId']),
      milestoneKey: serializer.fromJson<String>(json['milestoneKey']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'babyId': serializer.toJson<String>(babyId),
      'milestoneKey': serializer.toJson<String>(milestoneKey),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'note': serializer.toJson<String>(note),
    };
  }

  MilestoneAchievement copyWith({
    String? babyId,
    String? milestoneKey,
    DateTime? achievedAt,
    String? note,
  }) => MilestoneAchievement(
    babyId: babyId ?? this.babyId,
    milestoneKey: milestoneKey ?? this.milestoneKey,
    achievedAt: achievedAt ?? this.achievedAt,
    note: note ?? this.note,
  );
  MilestoneAchievement copyWithCompanion(MilestoneAchievementsCompanion data) {
    return MilestoneAchievement(
      babyId: data.babyId.present ? data.babyId.value : this.babyId,
      milestoneKey: data.milestoneKey.present
          ? data.milestoneKey.value
          : this.milestoneKey,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneAchievement(')
          ..write('babyId: $babyId, ')
          ..write('milestoneKey: $milestoneKey, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(babyId, milestoneKey, achievedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneAchievement &&
          other.babyId == this.babyId &&
          other.milestoneKey == this.milestoneKey &&
          other.achievedAt == this.achievedAt &&
          other.note == this.note);
}

class MilestoneAchievementsCompanion
    extends UpdateCompanion<MilestoneAchievement> {
  final Value<String> babyId;
  final Value<String> milestoneKey;
  final Value<DateTime> achievedAt;
  final Value<String> note;
  final Value<int> rowid;
  const MilestoneAchievementsCompanion({
    this.babyId = const Value.absent(),
    this.milestoneKey = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestoneAchievementsCompanion.insert({
    required String babyId,
    required String milestoneKey,
    required DateTime achievedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : babyId = Value(babyId),
       milestoneKey = Value(milestoneKey),
       achievedAt = Value(achievedAt);
  static Insertable<MilestoneAchievement> custom({
    Expression<String>? babyId,
    Expression<String>? milestoneKey,
    Expression<DateTime>? achievedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (babyId != null) 'baby_id': babyId,
      if (milestoneKey != null) 'milestone_key': milestoneKey,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestoneAchievementsCompanion copyWith({
    Value<String>? babyId,
    Value<String>? milestoneKey,
    Value<DateTime>? achievedAt,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return MilestoneAchievementsCompanion(
      babyId: babyId ?? this.babyId,
      milestoneKey: milestoneKey ?? this.milestoneKey,
      achievedAt: achievedAt ?? this.achievedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (babyId.present) {
      map['baby_id'] = Variable<String>(babyId.value);
    }
    if (milestoneKey.present) {
      map['milestone_key'] = Variable<String>(milestoneKey.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneAchievementsCompanion(')
          ..write('babyId: $babyId, ')
          ..write('milestoneKey: $milestoneKey, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BabiesTable babies = $BabiesTable(this);
  late final $CareEventsTable careEvents = $CareEventsTable(this);
  late final $PregnancyProfilesTable pregnancyProfiles =
      $PregnancyProfilesTable(this);
  late final $PregnancyAppointmentsTable pregnancyAppointments =
      $PregnancyAppointmentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $GrowthMeasurementsTable growthMeasurements =
      $GrowthMeasurementsTable(this);
  late final $MilestoneAchievementsTable milestoneAchievements =
      $MilestoneAchievementsTable(this);
  late final CareLogDao careLogDao = CareLogDao(this as AppDatabase);
  late final GrowthDao growthDao = GrowthDao(this as AppDatabase);
  late final PregnancyDao pregnancyDao = PregnancyDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    babies,
    careEvents,
    pregnancyProfiles,
    pregnancyAppointments,
    appSettings,
    growthMeasurements,
    milestoneAchievements,
  ];
}

typedef $$BabiesTableCreateCompanionBuilder =
    BabiesCompanion Function({
      required String id,
      required String name,
      Value<DateTime?> birthDate,
      Value<bool> isPreemie,
      required DateTime createdAt,
      Value<String?> serverChildId,
      Value<int> rowid,
    });
typedef $$BabiesTableUpdateCompanionBuilder =
    BabiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime?> birthDate,
      Value<bool> isPreemie,
      Value<DateTime> createdAt,
      Value<String?> serverChildId,
      Value<int> rowid,
    });

class $$BabiesTableFilterComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreemie => $composableBuilder(
    column: $table.isPreemie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverChildId => $composableBuilder(
    column: $table.serverChildId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BabiesTableOrderingComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreemie => $composableBuilder(
    column: $table.isPreemie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverChildId => $composableBuilder(
    column: $table.serverChildId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BabiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BabiesTable> {
  $$BabiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<bool> get isPreemie =>
      $composableBuilder(column: $table.isPreemie, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get serverChildId => $composableBuilder(
    column: $table.serverChildId,
    builder: (column) => column,
  );
}

class $$BabiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BabiesTable,
          Baby,
          $$BabiesTableFilterComposer,
          $$BabiesTableOrderingComposer,
          $$BabiesTableAnnotationComposer,
          $$BabiesTableCreateCompanionBuilder,
          $$BabiesTableUpdateCompanionBuilder,
          (Baby, BaseReferences<_$AppDatabase, $BabiesTable, Baby>),
          Baby,
          PrefetchHooks Function()
        > {
  $$BabiesTableTableManager(_$AppDatabase db, $BabiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BabiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BabiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BabiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<bool> isPreemie = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> serverChildId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BabiesCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                isPreemie: isPreemie,
                createdAt: createdAt,
                serverChildId: serverChildId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<bool> isPreemie = const Value.absent(),
                required DateTime createdAt,
                Value<String?> serverChildId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BabiesCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                isPreemie: isPreemie,
                createdAt: createdAt,
                serverChildId: serverChildId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BabiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BabiesTable,
      Baby,
      $$BabiesTableFilterComposer,
      $$BabiesTableOrderingComposer,
      $$BabiesTableAnnotationComposer,
      $$BabiesTableCreateCompanionBuilder,
      $$BabiesTableUpdateCompanionBuilder,
      (Baby, BaseReferences<_$AppDatabase, $BabiesTable, Baby>),
      Baby,
      PrefetchHooks Function()
    >;
typedef $$CareEventsTableCreateCompanionBuilder =
    CareEventsCompanion Function({
      required String id,
      required String babyId,
      required String type,
      required DateTime occurredAt,
      Value<String> detailsJson,
      Value<String> note,
      required DateTime clientUpdatedAt,
      Value<bool> pendingSync,
      Value<DateTime?> deletedAt,
      Value<String?> loggedByUserId,
      Value<String?> loggedByDisplayName,
      Value<int> rowid,
    });
typedef $$CareEventsTableUpdateCompanionBuilder =
    CareEventsCompanion Function({
      Value<String> id,
      Value<String> babyId,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String> detailsJson,
      Value<String> note,
      Value<DateTime> clientUpdatedAt,
      Value<bool> pendingSync,
      Value<DateTime?> deletedAt,
      Value<String?> loggedByUserId,
      Value<String?> loggedByDisplayName,
      Value<int> rowid,
    });

class $$CareEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loggedByUserId => $composableBuilder(
    column: $table.loggedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loggedByDisplayName => $composableBuilder(
    column: $table.loggedByDisplayName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CareEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get babyId => $composableBuilder(
    column: $table.babyId,
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

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedByUserId => $composableBuilder(
    column: $table.loggedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loggedByDisplayName => $composableBuilder(
    column: $table.loggedByDisplayName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CareEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareEventsTable> {
  $$CareEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get loggedByUserId => $composableBuilder(
    column: $table.loggedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loggedByDisplayName => $composableBuilder(
    column: $table.loggedByDisplayName,
    builder: (column) => column,
  );
}

class $$CareEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareEventsTable,
          CareEvent,
          $$CareEventsTableFilterComposer,
          $$CareEventsTableOrderingComposer,
          $$CareEventsTableAnnotationComposer,
          $$CareEventsTableCreateCompanionBuilder,
          $$CareEventsTableUpdateCompanionBuilder,
          (
            CareEvent,
            BaseReferences<_$AppDatabase, $CareEventsTable, CareEvent>,
          ),
          CareEvent,
          PrefetchHooks Function()
        > {
  $$CareEventsTableTableManager(_$AppDatabase db, $CareEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> babyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> clientUpdatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> loggedByUserId = const Value.absent(),
                Value<String?> loggedByDisplayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareEventsCompanion(
                id: id,
                babyId: babyId,
                type: type,
                occurredAt: occurredAt,
                detailsJson: detailsJson,
                note: note,
                clientUpdatedAt: clientUpdatedAt,
                pendingSync: pendingSync,
                deletedAt: deletedAt,
                loggedByUserId: loggedByUserId,
                loggedByDisplayName: loggedByDisplayName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String babyId,
                required String type,
                required DateTime occurredAt,
                Value<String> detailsJson = const Value.absent(),
                Value<String> note = const Value.absent(),
                required DateTime clientUpdatedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> loggedByUserId = const Value.absent(),
                Value<String?> loggedByDisplayName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareEventsCompanion.insert(
                id: id,
                babyId: babyId,
                type: type,
                occurredAt: occurredAt,
                detailsJson: detailsJson,
                note: note,
                clientUpdatedAt: clientUpdatedAt,
                pendingSync: pendingSync,
                deletedAt: deletedAt,
                loggedByUserId: loggedByUserId,
                loggedByDisplayName: loggedByDisplayName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CareEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareEventsTable,
      CareEvent,
      $$CareEventsTableFilterComposer,
      $$CareEventsTableOrderingComposer,
      $$CareEventsTableAnnotationComposer,
      $$CareEventsTableCreateCompanionBuilder,
      $$CareEventsTableUpdateCompanionBuilder,
      (CareEvent, BaseReferences<_$AppDatabase, $CareEventsTable, CareEvent>),
      CareEvent,
      PrefetchHooks Function()
    >;
typedef $$PregnancyProfilesTableCreateCompanionBuilder =
    PregnancyProfilesCompanion Function({
      required String id,
      Value<DateTime?> dueDate,
      Value<int> kickCountToday,
      Value<DateTime?> kickCountDate,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PregnancyProfilesTableUpdateCompanionBuilder =
    PregnancyProfilesCompanion Function({
      Value<String> id,
      Value<DateTime?> dueDate,
      Value<int> kickCountToday,
      Value<DateTime?> kickCountDate,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PregnancyProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PregnancyProfilesTable> {
  $$PregnancyProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kickCountToday => $composableBuilder(
    column: $table.kickCountToday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get kickCountDate => $composableBuilder(
    column: $table.kickCountDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PregnancyProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PregnancyProfilesTable> {
  $$PregnancyProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kickCountToday => $composableBuilder(
    column: $table.kickCountToday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get kickCountDate => $composableBuilder(
    column: $table.kickCountDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PregnancyProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PregnancyProfilesTable> {
  $$PregnancyProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get kickCountToday => $composableBuilder(
    column: $table.kickCountToday,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get kickCountDate => $composableBuilder(
    column: $table.kickCountDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PregnancyProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PregnancyProfilesTable,
          PregnancyProfile,
          $$PregnancyProfilesTableFilterComposer,
          $$PregnancyProfilesTableOrderingComposer,
          $$PregnancyProfilesTableAnnotationComposer,
          $$PregnancyProfilesTableCreateCompanionBuilder,
          $$PregnancyProfilesTableUpdateCompanionBuilder,
          (
            PregnancyProfile,
            BaseReferences<
              _$AppDatabase,
              $PregnancyProfilesTable,
              PregnancyProfile
            >,
          ),
          PregnancyProfile,
          PrefetchHooks Function()
        > {
  $$PregnancyProfilesTableTableManager(
    _$AppDatabase db,
    $PregnancyProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PregnancyProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PregnancyProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PregnancyProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> kickCountToday = const Value.absent(),
                Value<DateTime?> kickCountDate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PregnancyProfilesCompanion(
                id: id,
                dueDate: dueDate,
                kickCountToday: kickCountToday,
                kickCountDate: kickCountDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> kickCountToday = const Value.absent(),
                Value<DateTime?> kickCountDate = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PregnancyProfilesCompanion.insert(
                id: id,
                dueDate: dueDate,
                kickCountToday: kickCountToday,
                kickCountDate: kickCountDate,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PregnancyProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PregnancyProfilesTable,
      PregnancyProfile,
      $$PregnancyProfilesTableFilterComposer,
      $$PregnancyProfilesTableOrderingComposer,
      $$PregnancyProfilesTableAnnotationComposer,
      $$PregnancyProfilesTableCreateCompanionBuilder,
      $$PregnancyProfilesTableUpdateCompanionBuilder,
      (
        PregnancyProfile,
        BaseReferences<
          _$AppDatabase,
          $PregnancyProfilesTable,
          PregnancyProfile
        >,
      ),
      PregnancyProfile,
      PrefetchHooks Function()
    >;
typedef $$PregnancyAppointmentsTableCreateCompanionBuilder =
    PregnancyAppointmentsCompanion Function({
      required String id,
      required String title,
      Value<DateTime?> scheduledAt,
      Value<String> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PregnancyAppointmentsTableUpdateCompanionBuilder =
    PregnancyAppointmentsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime?> scheduledAt,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PregnancyAppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PregnancyAppointmentsTable> {
  $$PregnancyAppointmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PregnancyAppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PregnancyAppointmentsTable> {
  $$PregnancyAppointmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PregnancyAppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PregnancyAppointmentsTable> {
  $$PregnancyAppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PregnancyAppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PregnancyAppointmentsTable,
          PregnancyAppointment,
          $$PregnancyAppointmentsTableFilterComposer,
          $$PregnancyAppointmentsTableOrderingComposer,
          $$PregnancyAppointmentsTableAnnotationComposer,
          $$PregnancyAppointmentsTableCreateCompanionBuilder,
          $$PregnancyAppointmentsTableUpdateCompanionBuilder,
          (
            PregnancyAppointment,
            BaseReferences<
              _$AppDatabase,
              $PregnancyAppointmentsTable,
              PregnancyAppointment
            >,
          ),
          PregnancyAppointment,
          PrefetchHooks Function()
        > {
  $$PregnancyAppointmentsTableTableManager(
    _$AppDatabase db,
    $PregnancyAppointmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PregnancyAppointmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PregnancyAppointmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PregnancyAppointmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PregnancyAppointmentsCompanion(
                id: id,
                title: title,
                scheduledAt: scheduledAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PregnancyAppointmentsCompanion.insert(
                id: id,
                title: title,
                scheduledAt: scheduledAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PregnancyAppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PregnancyAppointmentsTable,
      PregnancyAppointment,
      $$PregnancyAppointmentsTableFilterComposer,
      $$PregnancyAppointmentsTableOrderingComposer,
      $$PregnancyAppointmentsTableAnnotationComposer,
      $$PregnancyAppointmentsTableCreateCompanionBuilder,
      $$PregnancyAppointmentsTableUpdateCompanionBuilder,
      (
        PregnancyAppointment,
        BaseReferences<
          _$AppDatabase,
          $PregnancyAppointmentsTable,
          PregnancyAppointment
        >,
      ),
      PregnancyAppointment,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> onboardingCompleted,
      Value<bool> useImperialUnits,
      Value<bool> partnerActivityPushEnabled,
      Value<bool> partnerGentleNudgeEnabled,
      Value<String> themeMode,
      Value<String?> lastSignedInUserId,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> onboardingCompleted,
      Value<bool> useImperialUnits,
      Value<bool> partnerActivityPushEnabled,
      Value<bool> partnerGentleNudgeEnabled,
      Value<String> themeMode,
      Value<String?> lastSignedInUserId,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get useImperialUnits => $composableBuilder(
    column: $table.useImperialUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get partnerActivityPushEnabled => $composableBuilder(
    column: $table.partnerActivityPushEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get partnerGentleNudgeEnabled => $composableBuilder(
    column: $table.partnerGentleNudgeEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSignedInUserId => $composableBuilder(
    column: $table.lastSignedInUserId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useImperialUnits => $composableBuilder(
    column: $table.useImperialUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get partnerActivityPushEnabled => $composableBuilder(
    column: $table.partnerActivityPushEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get partnerGentleNudgeEnabled => $composableBuilder(
    column: $table.partnerGentleNudgeEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSignedInUserId => $composableBuilder(
    column: $table.lastSignedInUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get useImperialUnits => $composableBuilder(
    column: $table.useImperialUnits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get partnerActivityPushEnabled => $composableBuilder(
    column: $table.partnerActivityPushEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get partnerGentleNudgeEnabled => $composableBuilder(
    column: $table.partnerGentleNudgeEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get lastSignedInUserId => $composableBuilder(
    column: $table.lastSignedInUserId,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> useImperialUnits = const Value.absent(),
                Value<bool> partnerActivityPushEnabled = const Value.absent(),
                Value<bool> partnerGentleNudgeEnabled = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> lastSignedInUserId = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                onboardingCompleted: onboardingCompleted,
                useImperialUnits: useImperialUnits,
                partnerActivityPushEnabled: partnerActivityPushEnabled,
                partnerGentleNudgeEnabled: partnerGentleNudgeEnabled,
                themeMode: themeMode,
                lastSignedInUserId: lastSignedInUserId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<bool> useImperialUnits = const Value.absent(),
                Value<bool> partnerActivityPushEnabled = const Value.absent(),
                Value<bool> partnerGentleNudgeEnabled = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String?> lastSignedInUserId = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                onboardingCompleted: onboardingCompleted,
                useImperialUnits: useImperialUnits,
                partnerActivityPushEnabled: partnerActivityPushEnabled,
                partnerGentleNudgeEnabled: partnerGentleNudgeEnabled,
                themeMode: themeMode,
                lastSignedInUserId: lastSignedInUserId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$GrowthMeasurementsTableCreateCompanionBuilder =
    GrowthMeasurementsCompanion Function({
      required String id,
      required String babyId,
      required DateTime measuredAt,
      Value<double?> weightKg,
      Value<double?> lengthCm,
      Value<double?> headCm,
      Value<String> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GrowthMeasurementsTableUpdateCompanionBuilder =
    GrowthMeasurementsCompanion Function({
      Value<String> id,
      Value<String> babyId,
      Value<DateTime> measuredAt,
      Value<double?> weightKg,
      Value<double?> lengthCm,
      Value<double?> headCm,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$GrowthMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $GrowthMeasurementsTable> {
  $$GrowthMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headCm => $composableBuilder(
    column: $table.headCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrowthMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrowthMeasurementsTable> {
  $$GrowthMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthCm => $composableBuilder(
    column: $table.lengthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headCm => $composableBuilder(
    column: $table.headCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrowthMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrowthMeasurementsTable> {
  $$GrowthMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<double> get headCm =>
      $composableBuilder(column: $table.headCm, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GrowthMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrowthMeasurementsTable,
          GrowthMeasurement,
          $$GrowthMeasurementsTableFilterComposer,
          $$GrowthMeasurementsTableOrderingComposer,
          $$GrowthMeasurementsTableAnnotationComposer,
          $$GrowthMeasurementsTableCreateCompanionBuilder,
          $$GrowthMeasurementsTableUpdateCompanionBuilder,
          (
            GrowthMeasurement,
            BaseReferences<
              _$AppDatabase,
              $GrowthMeasurementsTable,
              GrowthMeasurement
            >,
          ),
          GrowthMeasurement,
          PrefetchHooks Function()
        > {
  $$GrowthMeasurementsTableTableManager(
    _$AppDatabase db,
    $GrowthMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrowthMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrowthMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrowthMeasurementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> babyId = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<double?> headCm = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrowthMeasurementsCompanion(
                id: id,
                babyId: babyId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                lengthCm: lengthCm,
                headCm: headCm,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String babyId,
                required DateTime measuredAt,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<double?> headCm = const Value.absent(),
                Value<String> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GrowthMeasurementsCompanion.insert(
                id: id,
                babyId: babyId,
                measuredAt: measuredAt,
                weightKg: weightKg,
                lengthCm: lengthCm,
                headCm: headCm,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrowthMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrowthMeasurementsTable,
      GrowthMeasurement,
      $$GrowthMeasurementsTableFilterComposer,
      $$GrowthMeasurementsTableOrderingComposer,
      $$GrowthMeasurementsTableAnnotationComposer,
      $$GrowthMeasurementsTableCreateCompanionBuilder,
      $$GrowthMeasurementsTableUpdateCompanionBuilder,
      (
        GrowthMeasurement,
        BaseReferences<
          _$AppDatabase,
          $GrowthMeasurementsTable,
          GrowthMeasurement
        >,
      ),
      GrowthMeasurement,
      PrefetchHooks Function()
    >;
typedef $$MilestoneAchievementsTableCreateCompanionBuilder =
    MilestoneAchievementsCompanion Function({
      required String babyId,
      required String milestoneKey,
      required DateTime achievedAt,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$MilestoneAchievementsTableUpdateCompanionBuilder =
    MilestoneAchievementsCompanion Function({
      Value<String> babyId,
      Value<String> milestoneKey,
      Value<DateTime> achievedAt,
      Value<String> note,
      Value<int> rowid,
    });

class $$MilestoneAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $MilestoneAchievementsTable> {
  $$MilestoneAchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get milestoneKey => $composableBuilder(
    column: $table.milestoneKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MilestoneAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestoneAchievementsTable> {
  $$MilestoneAchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get babyId => $composableBuilder(
    column: $table.babyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milestoneKey => $composableBuilder(
    column: $table.milestoneKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MilestoneAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestoneAchievementsTable> {
  $$MilestoneAchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get babyId =>
      $composableBuilder(column: $table.babyId, builder: (column) => column);

  GeneratedColumn<String> get milestoneKey => $composableBuilder(
    column: $table.milestoneKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MilestoneAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestoneAchievementsTable,
          MilestoneAchievement,
          $$MilestoneAchievementsTableFilterComposer,
          $$MilestoneAchievementsTableOrderingComposer,
          $$MilestoneAchievementsTableAnnotationComposer,
          $$MilestoneAchievementsTableCreateCompanionBuilder,
          $$MilestoneAchievementsTableUpdateCompanionBuilder,
          (
            MilestoneAchievement,
            BaseReferences<
              _$AppDatabase,
              $MilestoneAchievementsTable,
              MilestoneAchievement
            >,
          ),
          MilestoneAchievement,
          PrefetchHooks Function()
        > {
  $$MilestoneAchievementsTableTableManager(
    _$AppDatabase db,
    $MilestoneAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestoneAchievementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MilestoneAchievementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MilestoneAchievementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> babyId = const Value.absent(),
                Value<String> milestoneKey = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestoneAchievementsCompanion(
                babyId: babyId,
                milestoneKey: milestoneKey,
                achievedAt: achievedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String babyId,
                required String milestoneKey,
                required DateTime achievedAt,
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestoneAchievementsCompanion.insert(
                babyId: babyId,
                milestoneKey: milestoneKey,
                achievedAt: achievedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MilestoneAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestoneAchievementsTable,
      MilestoneAchievement,
      $$MilestoneAchievementsTableFilterComposer,
      $$MilestoneAchievementsTableOrderingComposer,
      $$MilestoneAchievementsTableAnnotationComposer,
      $$MilestoneAchievementsTableCreateCompanionBuilder,
      $$MilestoneAchievementsTableUpdateCompanionBuilder,
      (
        MilestoneAchievement,
        BaseReferences<
          _$AppDatabase,
          $MilestoneAchievementsTable,
          MilestoneAchievement
        >,
      ),
      MilestoneAchievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BabiesTableTableManager get babies =>
      $$BabiesTableTableManager(_db, _db.babies);
  $$CareEventsTableTableManager get careEvents =>
      $$CareEventsTableTableManager(_db, _db.careEvents);
  $$PregnancyProfilesTableTableManager get pregnancyProfiles =>
      $$PregnancyProfilesTableTableManager(_db, _db.pregnancyProfiles);
  $$PregnancyAppointmentsTableTableManager get pregnancyAppointments =>
      $$PregnancyAppointmentsTableTableManager(_db, _db.pregnancyAppointments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$GrowthMeasurementsTableTableManager get growthMeasurements =>
      $$GrowthMeasurementsTableTableManager(_db, _db.growthMeasurements);
  $$MilestoneAchievementsTableTableManager get milestoneAchievements =>
      $$MilestoneAchievementsTableTableManager(_db, _db.milestoneAchievements);
}
