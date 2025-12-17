// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isGuestMeta =
      const VerificationMeta('isGuest');
  @override
  late final GeneratedColumn<bool> isGuest = GeneratedColumn<bool>(
      'is_guest', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_guest" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, color, avatar, isGuest, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(Insertable<Player> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('is_guest')) {
      context.handle(_isGuestMeta,
          isGuest.isAcceptableOrUnknown(data['is_guest']!, _isGuestMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      isGuest: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_guest'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final String name;
  final int color;
  final String? avatar;
  final bool isGuest;
  final DateTime createdAt;
  const Player(
      {required this.id,
      required this.name,
      required this.color,
      this.avatar,
      required this.isGuest,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['is_guest'] = Variable<bool>(isGuest);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      isGuest: Value(isGuest),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      isGuest: serializer.fromJson<bool>(json['isGuest']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'avatar': serializer.toJson<String?>(avatar),
      'isGuest': serializer.toJson<bool>(isGuest),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith(
          {String? id,
          String? name,
          int? color,
          Value<String?> avatar = const Value.absent(),
          bool? isGuest,
          DateTime? createdAt}) =>
      Player(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        avatar: avatar.present ? avatar.value : this.avatar,
        isGuest: isGuest ?? this.isGuest,
        createdAt: createdAt ?? this.createdAt,
      );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      isGuest: data.isGuest.present ? data.isGuest.value : this.isGuest,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('avatar: $avatar, ')
          ..write('isGuest: $isGuest, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, avatar, isGuest, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.avatar == this.avatar &&
          other.isGuest == this.isGuest &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String?> avatar;
  final Value<bool> isGuest;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.avatar = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String name,
    required int color,
    this.avatar = const Value.absent(),
    this.isGuest = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? avatar,
    Expression<bool>? isGuest,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (avatar != null) 'avatar': avatar,
      if (isGuest != null) 'is_guest': isGuest,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? color,
      Value<String?>? avatar,
      Value<bool>? isGuest,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      avatar: avatar ?? this.avatar,
      isGuest: isGuest ?? this.isGuest,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (isGuest.present) {
      map['is_guest'] = Variable<bool>(isGuest.value);
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
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('avatar: $avatar, ')
          ..write('isGuest: $isGuest, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(Insertable<Location> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final String id;
  final String name;
  final DateTime createdAt;
  const Location(
      {required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Location.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Location copyWith({String? id, String? name, DateTime? createdAt}) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Location> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeaguesTable extends Leagues with TableInfo<$LeaguesTable, League> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaguesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerTypeMeta =
      const VerificationMeta('providerType');
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
      'provider_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteRootMeta =
      const VerificationMeta('remoteRoot');
  @override
  late final GeneratedColumn<String> remoteRoot = GeneratedColumn<String>(
      'remote_root', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inviteCodeMeta =
      const VerificationMeta('inviteCode');
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
      'invite_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, providerType, remoteRoot, inviteCode, createdAt, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leagues';
  @override
  VerificationContext validateIntegrity(Insertable<League> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider_type')) {
      context.handle(
          _providerTypeMeta,
          providerType.isAcceptableOrUnknown(
              data['provider_type']!, _providerTypeMeta));
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('remote_root')) {
      context.handle(
          _remoteRootMeta,
          remoteRoot.isAcceptableOrUnknown(
              data['remote_root']!, _remoteRootMeta));
    }
    if (data.containsKey('invite_code')) {
      context.handle(
          _inviteCodeMeta,
          inviteCode.isAcceptableOrUnknown(
              data['invite_code']!, _inviteCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  League map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return League(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      providerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_type'])!,
      remoteRoot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_root']),
      inviteCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invite_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at']),
    );
  }

  @override
  $LeaguesTable createAlias(String alias) {
    return $LeaguesTable(attachedDatabase, alias);
  }
}

class League extends DataClass implements Insertable<League> {
  final String id;
  final String name;
  final String providerType;
  final String? remoteRoot;
  final String? inviteCode;
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  const League(
      {required this.id,
      required this.name,
      required this.providerType,
      this.remoteRoot,
      this.inviteCode,
      required this.createdAt,
      this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['provider_type'] = Variable<String>(providerType);
    if (!nullToAbsent || remoteRoot != null) {
      map['remote_root'] = Variable<String>(remoteRoot);
    }
    if (!nullToAbsent || inviteCode != null) {
      map['invite_code'] = Variable<String>(inviteCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  LeaguesCompanion toCompanion(bool nullToAbsent) {
    return LeaguesCompanion(
      id: Value(id),
      name: Value(name),
      providerType: Value(providerType),
      remoteRoot: remoteRoot == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteRoot),
      inviteCode: inviteCode == null && nullToAbsent
          ? const Value.absent()
          : Value(inviteCode),
      createdAt: Value(createdAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory League.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return League(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      providerType: serializer.fromJson<String>(json['providerType']),
      remoteRoot: serializer.fromJson<String?>(json['remoteRoot']),
      inviteCode: serializer.fromJson<String?>(json['inviteCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'providerType': serializer.toJson<String>(providerType),
      'remoteRoot': serializer.toJson<String?>(remoteRoot),
      'inviteCode': serializer.toJson<String?>(inviteCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  League copyWith(
          {String? id,
          String? name,
          String? providerType,
          Value<String?> remoteRoot = const Value.absent(),
          Value<String?> inviteCode = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastSyncAt = const Value.absent()}) =>
      League(
        id: id ?? this.id,
        name: name ?? this.name,
        providerType: providerType ?? this.providerType,
        remoteRoot: remoteRoot.present ? remoteRoot.value : this.remoteRoot,
        inviteCode: inviteCode.present ? inviteCode.value : this.inviteCode,
        createdAt: createdAt ?? this.createdAt,
        lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
      );
  League copyWithCompanion(LeaguesCompanion data) {
    return League(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      remoteRoot:
          data.remoteRoot.present ? data.remoteRoot.value : this.remoteRoot,
      inviteCode:
          data.inviteCode.present ? data.inviteCode.value : this.inviteCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('League(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('providerType: $providerType, ')
          ..write('remoteRoot: $remoteRoot, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, providerType, remoteRoot, inviteCode, createdAt, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is League &&
          other.id == this.id &&
          other.name == this.name &&
          other.providerType == this.providerType &&
          other.remoteRoot == this.remoteRoot &&
          other.inviteCode == this.inviteCode &&
          other.createdAt == this.createdAt &&
          other.lastSyncAt == this.lastSyncAt);
}

class LeaguesCompanion extends UpdateCompanion<League> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> providerType;
  final Value<String?> remoteRoot;
  final Value<String?> inviteCode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const LeaguesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.providerType = const Value.absent(),
    this.remoteRoot = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeaguesCompanion.insert({
    required String id,
    required String name,
    required String providerType,
    this.remoteRoot = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        providerType = Value(providerType);
  static Insertable<League> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? providerType,
    Expression<String>? remoteRoot,
    Expression<String>? inviteCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (providerType != null) 'provider_type': providerType,
      if (remoteRoot != null) 'remote_root': remoteRoot,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeaguesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? providerType,
      Value<String?>? remoteRoot,
      Value<String?>? inviteCode,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastSyncAt,
      Value<int>? rowid}) {
    return LeaguesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      providerType: providerType ?? this.providerType,
      remoteRoot: remoteRoot ?? this.remoteRoot,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
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
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (remoteRoot.present) {
      map['remote_root'] = Variable<String>(remoteRoot.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaguesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('providerType: $providerType, ')
          ..write('remoteRoot: $remoteRoot, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, Matche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gameTypeMeta =
      const VerificationMeta('gameType');
  @override
  late final GeneratedColumnWithTypeConverter<GameType, String> gameType =
      GeneratedColumn<String>('game_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<GameType>($MatchesTable.$convertergameType);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES locations (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _finishedAtMeta =
      const VerificationMeta('finishedAt');
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
      'finished_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _winnerIdMeta =
      const VerificationMeta('winnerId');
  @override
  late final GeneratedColumn<String> winnerId = GeneratedColumn<String>(
      'winner_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES players (id)'));
  static const VerificationMeta _settingsJsonMeta =
      const VerificationMeta('settingsJson');
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
      'settings_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCanceledMeta =
      const VerificationMeta('isCanceled');
  @override
  late final GeneratedColumn<bool> isCanceled = GeneratedColumn<bool>(
      'is_canceled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_canceled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _leagueIdMeta =
      const VerificationMeta('leagueId');
  @override
  late final GeneratedColumn<String> leagueId = GeneratedColumn<String>(
      'league_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES leagues (id)'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        gameType,
        locationId,
        createdAt,
        finishedAt,
        winnerId,
        settingsJson,
        isCanceled,
        source,
        leagueId,
        remoteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(Insertable<Matche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_gameTypeMeta, const VerificationResult.success());
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('finished_at')) {
      context.handle(
          _finishedAtMeta,
          finishedAt.isAcceptableOrUnknown(
              data['finished_at']!, _finishedAtMeta));
    }
    if (data.containsKey('winner_id')) {
      context.handle(_winnerIdMeta,
          winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta));
    }
    if (data.containsKey('settings_json')) {
      context.handle(
          _settingsJsonMeta,
          settingsJson.isAcceptableOrUnknown(
              data['settings_json']!, _settingsJsonMeta));
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('is_canceled')) {
      context.handle(
          _isCanceledMeta,
          isCanceled.isAcceptableOrUnknown(
              data['is_canceled']!, _isCanceledMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('league_id')) {
      context.handle(_leagueIdMeta,
          leagueId.isAcceptableOrUnknown(data['league_id']!, _leagueIdMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Matche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Matche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      gameType: $MatchesTable.$convertergameType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_type'])!),
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      finishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}finished_at']),
      winnerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}winner_id']),
      settingsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings_json'])!,
      isCanceled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_canceled'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      leagueId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}league_id']),
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }

  static TypeConverter<GameType, String> $convertergameType =
      const GameTypeConverter();
}

class Matche extends DataClass implements Insertable<Matche> {
  final String id;
  final GameType gameType;
  final String? locationId;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? winnerId;
  final String settingsJson;
  final bool isCanceled;
  final String source;
  final String? leagueId;
  final String? remoteId;
  const Matche(
      {required this.id,
      required this.gameType,
      this.locationId,
      required this.createdAt,
      this.finishedAt,
      this.winnerId,
      required this.settingsJson,
      required this.isCanceled,
      required this.source,
      this.leagueId,
      this.remoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['game_type'] =
          Variable<String>($MatchesTable.$convertergameType.toSql(gameType));
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<String>(winnerId);
    }
    map['settings_json'] = Variable<String>(settingsJson);
    map['is_canceled'] = Variable<bool>(isCanceled);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || leagueId != null) {
      map['league_id'] = Variable<String>(leagueId);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      gameType: Value(gameType),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      createdAt: Value(createdAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
      settingsJson: Value(settingsJson),
      isCanceled: Value(isCanceled),
      source: Value(source),
      leagueId: leagueId == null && nullToAbsent
          ? const Value.absent()
          : Value(leagueId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory Matche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Matche(
      id: serializer.fromJson<String>(json['id']),
      gameType: serializer.fromJson<GameType>(json['gameType']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      winnerId: serializer.fromJson<String?>(json['winnerId']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      isCanceled: serializer.fromJson<bool>(json['isCanceled']),
      source: serializer.fromJson<String>(json['source']),
      leagueId: serializer.fromJson<String?>(json['leagueId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameType': serializer.toJson<GameType>(gameType),
      'locationId': serializer.toJson<String?>(locationId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'winnerId': serializer.toJson<String?>(winnerId),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'isCanceled': serializer.toJson<bool>(isCanceled),
      'source': serializer.toJson<String>(source),
      'leagueId': serializer.toJson<String?>(leagueId),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  Matche copyWith(
          {String? id,
          GameType? gameType,
          Value<String?> locationId = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> finishedAt = const Value.absent(),
          Value<String?> winnerId = const Value.absent(),
          String? settingsJson,
          bool? isCanceled,
          String? source,
          Value<String?> leagueId = const Value.absent(),
          Value<String?> remoteId = const Value.absent()}) =>
      Matche(
        id: id ?? this.id,
        gameType: gameType ?? this.gameType,
        locationId: locationId.present ? locationId.value : this.locationId,
        createdAt: createdAt ?? this.createdAt,
        finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
        winnerId: winnerId.present ? winnerId.value : this.winnerId,
        settingsJson: settingsJson ?? this.settingsJson,
        isCanceled: isCanceled ?? this.isCanceled,
        source: source ?? this.source,
        leagueId: leagueId.present ? leagueId.value : this.leagueId,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
      );
  Matche copyWithCompanion(MatchesCompanion data) {
    return Matche(
      id: data.id.present ? data.id.value : this.id,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finishedAt:
          data.finishedAt.present ? data.finishedAt.value : this.finishedAt,
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      isCanceled:
          data.isCanceled.present ? data.isCanceled.value : this.isCanceled,
      source: data.source.present ? data.source.value : this.source,
      leagueId: data.leagueId.present ? data.leagueId.value : this.leagueId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Matche(')
          ..write('id: $id, ')
          ..write('gameType: $gameType, ')
          ..write('locationId: $locationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('winnerId: $winnerId, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('isCanceled: $isCanceled, ')
          ..write('source: $source, ')
          ..write('leagueId: $leagueId, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      gameType,
      locationId,
      createdAt,
      finishedAt,
      winnerId,
      settingsJson,
      isCanceled,
      source,
      leagueId,
      remoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Matche &&
          other.id == this.id &&
          other.gameType == this.gameType &&
          other.locationId == this.locationId &&
          other.createdAt == this.createdAt &&
          other.finishedAt == this.finishedAt &&
          other.winnerId == this.winnerId &&
          other.settingsJson == this.settingsJson &&
          other.isCanceled == this.isCanceled &&
          other.source == this.source &&
          other.leagueId == this.leagueId &&
          other.remoteId == this.remoteId);
}

class MatchesCompanion extends UpdateCompanion<Matche> {
  final Value<String> id;
  final Value<GameType> gameType;
  final Value<String?> locationId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> finishedAt;
  final Value<String?> winnerId;
  final Value<String> settingsJson;
  final Value<bool> isCanceled;
  final Value<String> source;
  final Value<String?> leagueId;
  final Value<String?> remoteId;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.gameType = const Value.absent(),
    this.locationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.winnerId = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.isCanceled = const Value.absent(),
    this.source = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    required GameType gameType,
    this.locationId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.winnerId = const Value.absent(),
    required String settingsJson,
    this.isCanceled = const Value.absent(),
    this.source = const Value.absent(),
    this.leagueId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        gameType = Value(gameType),
        settingsJson = Value(settingsJson);
  static Insertable<Matche> custom({
    Expression<String>? id,
    Expression<String>? gameType,
    Expression<String>? locationId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? winnerId,
    Expression<String>? settingsJson,
    Expression<bool>? isCanceled,
    Expression<String>? source,
    Expression<String>? leagueId,
    Expression<String>? remoteId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameType != null) 'game_type': gameType,
      if (locationId != null) 'location_id': locationId,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (winnerId != null) 'winner_id': winnerId,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (isCanceled != null) 'is_canceled': isCanceled,
      if (source != null) 'source': source,
      if (leagueId != null) 'league_id': leagueId,
      if (remoteId != null) 'remote_id': remoteId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith(
      {Value<String>? id,
      Value<GameType>? gameType,
      Value<String?>? locationId,
      Value<DateTime>? createdAt,
      Value<DateTime?>? finishedAt,
      Value<String?>? winnerId,
      Value<String>? settingsJson,
      Value<bool>? isCanceled,
      Value<String>? source,
      Value<String?>? leagueId,
      Value<String?>? remoteId,
      Value<int>? rowid}) {
    return MatchesCompanion(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      locationId: locationId ?? this.locationId,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      winnerId: winnerId ?? this.winnerId,
      settingsJson: settingsJson ?? this.settingsJson,
      isCanceled: isCanceled ?? this.isCanceled,
      source: source ?? this.source,
      leagueId: leagueId ?? this.leagueId,
      remoteId: remoteId ?? this.remoteId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(
          $MatchesTable.$convertergameType.toSql(gameType.value));
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (winnerId.present) {
      map['winner_id'] = Variable<String>(winnerId.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (isCanceled.present) {
      map['is_canceled'] = Variable<bool>(isCanceled.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (leagueId.present) {
      map['league_id'] = Variable<String>(leagueId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('gameType: $gameType, ')
          ..write('locationId: $locationId, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('winnerId: $winnerId, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('isCanceled: $isCanceled, ')
          ..write('source: $source, ')
          ..write('leagueId: $leagueId, ')
          ..write('remoteId: $remoteId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchPlayersTable extends MatchPlayers
    with TableInfo<$MatchPlayersTable, MatchPlayer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES matches (id)'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES players (id)'));
  static const VerificationMeta _playerOrderMeta =
      const VerificationMeta('playerOrder');
  @override
  late final GeneratedColumn<int> playerOrder = GeneratedColumn<int>(
      'player_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [matchId, playerId, playerOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_players';
  @override
  VerificationContext validateIntegrity(Insertable<MatchPlayer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_order')) {
      context.handle(
          _playerOrderMeta,
          playerOrder.isAcceptableOrUnknown(
              data['player_order']!, _playerOrderMeta));
    } else if (isInserting) {
      context.missing(_playerOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, playerId};
  @override
  MatchPlayer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchPlayer(
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      playerOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}player_order'])!,
    );
  }

  @override
  $MatchPlayersTable createAlias(String alias) {
    return $MatchPlayersTable(attachedDatabase, alias);
  }
}

class MatchPlayer extends DataClass implements Insertable<MatchPlayer> {
  final String matchId;
  final String playerId;
  final int playerOrder;
  const MatchPlayer(
      {required this.matchId,
      required this.playerId,
      required this.playerOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['player_order'] = Variable<int>(playerOrder);
    return map;
  }

  MatchPlayersCompanion toCompanion(bool nullToAbsent) {
    return MatchPlayersCompanion(
      matchId: Value(matchId),
      playerId: Value(playerId),
      playerOrder: Value(playerOrder),
    );
  }

  factory MatchPlayer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchPlayer(
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      playerOrder: serializer.fromJson<int>(json['playerOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'playerOrder': serializer.toJson<int>(playerOrder),
    };
  }

  MatchPlayer copyWith({String? matchId, String? playerId, int? playerOrder}) =>
      MatchPlayer(
        matchId: matchId ?? this.matchId,
        playerId: playerId ?? this.playerId,
        playerOrder: playerOrder ?? this.playerOrder,
      );
  MatchPlayer copyWithCompanion(MatchPlayersCompanion data) {
    return MatchPlayer(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerOrder:
          data.playerOrder.present ? data.playerOrder.value : this.playerOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayer(')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerOrder: $playerOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(matchId, playerId, playerOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchPlayer &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.playerOrder == this.playerOrder);
}

class MatchPlayersCompanion extends UpdateCompanion<MatchPlayer> {
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<int> playerOrder;
  final Value<int> rowid;
  const MatchPlayersCompanion({
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchPlayersCompanion.insert({
    required String matchId,
    required String playerId,
    required int playerOrder,
    this.rowid = const Value.absent(),
  })  : matchId = Value(matchId),
        playerId = Value(playerId),
        playerOrder = Value(playerOrder);
  static Insertable<MatchPlayer> custom({
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<int>? playerOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (playerOrder != null) 'player_order': playerOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchPlayersCompanion copyWith(
      {Value<String>? matchId,
      Value<String>? playerId,
      Value<int>? playerOrder,
      Value<int>? rowid}) {
    return MatchPlayersCompanion(
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      playerOrder: playerOrder ?? this.playerOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (playerOrder.present) {
      map['player_order'] = Variable<int>(playerOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchPlayersCompanion(')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('playerOrder: $playerOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TurnsTable extends Turns with TableInfo<$TurnsTable, Turn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TurnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES matches (id)'));
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES players (id)'));
  static const VerificationMeta _legIndexMeta =
      const VerificationMeta('legIndex');
  @override
  late final GeneratedColumn<int> legIndex = GeneratedColumn<int>(
      'leg_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _setIndexMeta =
      const VerificationMeta('setIndex');
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
      'set_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roundIndexMeta =
      const VerificationMeta('roundIndex');
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
      'round_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dartsMeta = const VerificationMeta('darts');
  @override
  late final GeneratedColumnWithTypeConverter<List<Dart>, String> darts =
      GeneratedColumn<String>('darts', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<Dart>>($TurnsTable.$converterdarts);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dartsThrownMeta =
      const VerificationMeta('dartsThrown');
  @override
  late final GeneratedColumn<int> dartsThrown = GeneratedColumn<int>(
      'darts_thrown', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _startingScoreMeta =
      const VerificationMeta('startingScore');
  @override
  late final GeneratedColumn<int> startingScore = GeneratedColumn<int>(
      'starting_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        playerId,
        legIndex,
        setIndex,
        roundIndex,
        darts,
        score,
        dartsThrown,
        startingScore,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'turns';
  @override
  VerificationContext validateIntegrity(Insertable<Turn> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('leg_index')) {
      context.handle(_legIndexMeta,
          legIndex.isAcceptableOrUnknown(data['leg_index']!, _legIndexMeta));
    } else if (isInserting) {
      context.missing(_legIndexMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(_setIndexMeta,
          setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta));
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('round_index')) {
      context.handle(
          _roundIndexMeta,
          roundIndex.isAcceptableOrUnknown(
              data['round_index']!, _roundIndexMeta));
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    context.handle(_dartsMeta, const VerificationResult.success());
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('darts_thrown')) {
      context.handle(
          _dartsThrownMeta,
          dartsThrown.isAcceptableOrUnknown(
              data['darts_thrown']!, _dartsThrownMeta));
    }
    if (data.containsKey('starting_score')) {
      context.handle(
          _startingScoreMeta,
          startingScore.isAcceptableOrUnknown(
              data['starting_score']!, _startingScoreMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Turn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Turn(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      legIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leg_index'])!,
      setIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}set_index'])!,
      roundIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}round_index'])!,
      darts: $TurnsTable.$converterdarts.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}darts'])!),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score']),
      dartsThrown: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}darts_thrown']),
      startingScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}starting_score']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TurnsTable createAlias(String alias) {
    return $TurnsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<Dart>, String> $converterdarts =
      const DartsConverter();
}

class Turn extends DataClass implements Insertable<Turn> {
  final int id;
  final String matchId;
  final String playerId;
  final int legIndex;
  final int setIndex;
  final int roundIndex;
  final List<Dart> darts;
  final int? score;
  final int? dartsThrown;
  final int? startingScore;
  final DateTime createdAt;
  const Turn(
      {required this.id,
      required this.matchId,
      required this.playerId,
      required this.legIndex,
      required this.setIndex,
      required this.roundIndex,
      required this.darts,
      this.score,
      this.dartsThrown,
      this.startingScore,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['match_id'] = Variable<String>(matchId);
    map['player_id'] = Variable<String>(playerId);
    map['leg_index'] = Variable<int>(legIndex);
    map['set_index'] = Variable<int>(setIndex);
    map['round_index'] = Variable<int>(roundIndex);
    {
      map['darts'] = Variable<String>($TurnsTable.$converterdarts.toSql(darts));
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    if (!nullToAbsent || dartsThrown != null) {
      map['darts_thrown'] = Variable<int>(dartsThrown);
    }
    if (!nullToAbsent || startingScore != null) {
      map['starting_score'] = Variable<int>(startingScore);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TurnsCompanion toCompanion(bool nullToAbsent) {
    return TurnsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      playerId: Value(playerId),
      legIndex: Value(legIndex),
      setIndex: Value(setIndex),
      roundIndex: Value(roundIndex),
      darts: Value(darts),
      score:
          score == null && nullToAbsent ? const Value.absent() : Value(score),
      dartsThrown: dartsThrown == null && nullToAbsent
          ? const Value.absent()
          : Value(dartsThrown),
      startingScore: startingScore == null && nullToAbsent
          ? const Value.absent()
          : Value(startingScore),
      createdAt: Value(createdAt),
    );
  }

  factory Turn.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Turn(
      id: serializer.fromJson<int>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      legIndex: serializer.fromJson<int>(json['legIndex']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      darts: serializer.fromJson<List<Dart>>(json['darts']),
      score: serializer.fromJson<int?>(json['score']),
      dartsThrown: serializer.fromJson<int?>(json['dartsThrown']),
      startingScore: serializer.fromJson<int?>(json['startingScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'matchId': serializer.toJson<String>(matchId),
      'playerId': serializer.toJson<String>(playerId),
      'legIndex': serializer.toJson<int>(legIndex),
      'setIndex': serializer.toJson<int>(setIndex),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'darts': serializer.toJson<List<Dart>>(darts),
      'score': serializer.toJson<int?>(score),
      'dartsThrown': serializer.toJson<int?>(dartsThrown),
      'startingScore': serializer.toJson<int?>(startingScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Turn copyWith(
          {int? id,
          String? matchId,
          String? playerId,
          int? legIndex,
          int? setIndex,
          int? roundIndex,
          List<Dart>? darts,
          Value<int?> score = const Value.absent(),
          Value<int?> dartsThrown = const Value.absent(),
          Value<int?> startingScore = const Value.absent(),
          DateTime? createdAt}) =>
      Turn(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        playerId: playerId ?? this.playerId,
        legIndex: legIndex ?? this.legIndex,
        setIndex: setIndex ?? this.setIndex,
        roundIndex: roundIndex ?? this.roundIndex,
        darts: darts ?? this.darts,
        score: score.present ? score.value : this.score,
        dartsThrown: dartsThrown.present ? dartsThrown.value : this.dartsThrown,
        startingScore:
            startingScore.present ? startingScore.value : this.startingScore,
        createdAt: createdAt ?? this.createdAt,
      );
  Turn copyWithCompanion(TurnsCompanion data) {
    return Turn(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      legIndex: data.legIndex.present ? data.legIndex.value : this.legIndex,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      roundIndex:
          data.roundIndex.present ? data.roundIndex.value : this.roundIndex,
      darts: data.darts.present ? data.darts.value : this.darts,
      score: data.score.present ? data.score.value : this.score,
      dartsThrown:
          data.dartsThrown.present ? data.dartsThrown.value : this.dartsThrown,
      startingScore: data.startingScore.present
          ? data.startingScore.value
          : this.startingScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Turn(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('legIndex: $legIndex, ')
          ..write('setIndex: $setIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('darts: $darts, ')
          ..write('score: $score, ')
          ..write('dartsThrown: $dartsThrown, ')
          ..write('startingScore: $startingScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, matchId, playerId, legIndex, setIndex,
      roundIndex, darts, score, dartsThrown, startingScore, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Turn &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.playerId == this.playerId &&
          other.legIndex == this.legIndex &&
          other.setIndex == this.setIndex &&
          other.roundIndex == this.roundIndex &&
          other.darts == this.darts &&
          other.score == this.score &&
          other.dartsThrown == this.dartsThrown &&
          other.startingScore == this.startingScore &&
          other.createdAt == this.createdAt);
}

class TurnsCompanion extends UpdateCompanion<Turn> {
  final Value<int> id;
  final Value<String> matchId;
  final Value<String> playerId;
  final Value<int> legIndex;
  final Value<int> setIndex;
  final Value<int> roundIndex;
  final Value<List<Dart>> darts;
  final Value<int?> score;
  final Value<int?> dartsThrown;
  final Value<int?> startingScore;
  final Value<DateTime> createdAt;
  const TurnsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.legIndex = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.darts = const Value.absent(),
    this.score = const Value.absent(),
    this.dartsThrown = const Value.absent(),
    this.startingScore = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TurnsCompanion.insert({
    this.id = const Value.absent(),
    required String matchId,
    required String playerId,
    required int legIndex,
    required int setIndex,
    required int roundIndex,
    required List<Dart> darts,
    this.score = const Value.absent(),
    this.dartsThrown = const Value.absent(),
    this.startingScore = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : matchId = Value(matchId),
        playerId = Value(playerId),
        legIndex = Value(legIndex),
        setIndex = Value(setIndex),
        roundIndex = Value(roundIndex),
        darts = Value(darts);
  static Insertable<Turn> custom({
    Expression<int>? id,
    Expression<String>? matchId,
    Expression<String>? playerId,
    Expression<int>? legIndex,
    Expression<int>? setIndex,
    Expression<int>? roundIndex,
    Expression<String>? darts,
    Expression<int>? score,
    Expression<int>? dartsThrown,
    Expression<int>? startingScore,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (playerId != null) 'player_id': playerId,
      if (legIndex != null) 'leg_index': legIndex,
      if (setIndex != null) 'set_index': setIndex,
      if (roundIndex != null) 'round_index': roundIndex,
      if (darts != null) 'darts': darts,
      if (score != null) 'score': score,
      if (dartsThrown != null) 'darts_thrown': dartsThrown,
      if (startingScore != null) 'starting_score': startingScore,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TurnsCompanion copyWith(
      {Value<int>? id,
      Value<String>? matchId,
      Value<String>? playerId,
      Value<int>? legIndex,
      Value<int>? setIndex,
      Value<int>? roundIndex,
      Value<List<Dart>>? darts,
      Value<int?>? score,
      Value<int?>? dartsThrown,
      Value<int?>? startingScore,
      Value<DateTime>? createdAt}) {
    return TurnsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      legIndex: legIndex ?? this.legIndex,
      setIndex: setIndex ?? this.setIndex,
      roundIndex: roundIndex ?? this.roundIndex,
      darts: darts ?? this.darts,
      score: score ?? this.score,
      dartsThrown: dartsThrown ?? this.dartsThrown,
      startingScore: startingScore ?? this.startingScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (legIndex.present) {
      map['leg_index'] = Variable<int>(legIndex.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (darts.present) {
      map['darts'] =
          Variable<String>($TurnsTable.$converterdarts.toSql(darts.value));
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (dartsThrown.present) {
      map['darts_thrown'] = Variable<int>(dartsThrown.value);
    }
    if (startingScore.present) {
      map['starting_score'] = Variable<int>(startingScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TurnsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('playerId: $playerId, ')
          ..write('legIndex: $legIndex, ')
          ..write('setIndex: $setIndex, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('darts: $darts, ')
          ..write('score: $score, ')
          ..write('dartsThrown: $dartsThrown, ')
          ..write('startingScore: $startingScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $LeaguesTable leagues = $LeaguesTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $MatchPlayersTable matchPlayers = $MatchPlayersTable(this);
  late final $TurnsTable turns = $TurnsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [players, locations, leagues, matches, matchPlayers, turns];
}

typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required String id,
  required String name,
  required int color,
  Value<String?> avatar,
  Value<bool> isGuest,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> color,
  Value<String?> avatar,
  Value<bool> isGuest,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder> {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PlayersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PlayersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<bool> isGuest = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion(
            id: id,
            name: name,
            color: color,
            avatar: avatar,
            isGuest: isGuest,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int color,
            Value<String?> avatar = const Value.absent(),
            Value<bool> isGuest = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion.insert(
            id: id,
            name: name,
            color: color,
            avatar: avatar,
            isGuest: isGuest,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$PlayersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatar => $state.composableBuilder(
      column: $state.table.avatar,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isGuest => $state.composableBuilder(
      column: $state.table.isGuest,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter matchesRefs(
      ComposableFilter Function($$MatchesTableFilterComposer f) f) {
    final $$MatchesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.winnerId,
        builder: (joinBuilder, parentComposers) => $$MatchesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter matchPlayersRefs(
      ComposableFilter Function($$MatchPlayersTableFilterComposer f) f) {
    final $$MatchPlayersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.matchPlayers,
        getReferencedColumn: (t) => t.playerId,
        builder: (joinBuilder, parentComposers) =>
            $$MatchPlayersTableFilterComposer(ComposerState($state.db,
                $state.db.matchPlayers, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter turnsRefs(
      ComposableFilter Function($$TurnsTableFilterComposer f) f) {
    final $$TurnsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.turns,
        getReferencedColumn: (t) => t.playerId,
        builder: (joinBuilder, parentComposers) => $$TurnsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.turns, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatar => $state.composableBuilder(
      column: $state.table.avatar,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isGuest => $state.composableBuilder(
      column: $state.table.isGuest,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$LocationsTableCreateCompanionBuilder = LocationsCompanion Function({
  required String id,
  required String name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LocationsTableUpdateCompanionBuilder = LocationsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationsTable,
    Location,
    $$LocationsTableFilterComposer,
    $$LocationsTableOrderingComposer,
    $$LocationsTableCreateCompanionBuilder,
    $$LocationsTableUpdateCompanionBuilder> {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LocationsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LocationsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$LocationsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter matchesRefs(
      ComposableFilter Function($$MatchesTableFilterComposer f) f) {
    final $$MatchesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.locationId,
        builder: (joinBuilder, parentComposers) => $$MatchesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$LocationsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$LeaguesTableCreateCompanionBuilder = LeaguesCompanion Function({
  required String id,
  required String name,
  required String providerType,
  Value<String?> remoteRoot,
  Value<String?> inviteCode,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});
typedef $$LeaguesTableUpdateCompanionBuilder = LeaguesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> providerType,
  Value<String?> remoteRoot,
  Value<String?> inviteCode,
  Value<DateTime> createdAt,
  Value<DateTime?> lastSyncAt,
  Value<int> rowid,
});

class $$LeaguesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LeaguesTable,
    League,
    $$LeaguesTableFilterComposer,
    $$LeaguesTableOrderingComposer,
    $$LeaguesTableCreateCompanionBuilder,
    $$LeaguesTableUpdateCompanionBuilder> {
  $$LeaguesTableTableManager(_$AppDatabase db, $LeaguesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$LeaguesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$LeaguesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> providerType = const Value.absent(),
            Value<String?> remoteRoot = const Value.absent(),
            Value<String?> inviteCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LeaguesCompanion(
            id: id,
            name: name,
            providerType: providerType,
            remoteRoot: remoteRoot,
            inviteCode: inviteCode,
            createdAt: createdAt,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String providerType,
            Value<String?> remoteRoot = const Value.absent(),
            Value<String?> inviteCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LeaguesCompanion.insert(
            id: id,
            name: name,
            providerType: providerType,
            remoteRoot: remoteRoot,
            inviteCode: inviteCode,
            createdAt: createdAt,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
        ));
}

class $$LeaguesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $LeaguesTable> {
  $$LeaguesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get providerType => $state.composableBuilder(
      column: $state.table.providerType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteRoot => $state.composableBuilder(
      column: $state.table.remoteRoot,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get inviteCode => $state.composableBuilder(
      column: $state.table.inviteCode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSyncAt => $state.composableBuilder(
      column: $state.table.lastSyncAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter matchesRefs(
      ComposableFilter Function($$MatchesTableFilterComposer f) f) {
    final $$MatchesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.leagueId,
        builder: (joinBuilder, parentComposers) => $$MatchesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$LeaguesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $LeaguesTable> {
  $$LeaguesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get providerType => $state.composableBuilder(
      column: $state.table.providerType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteRoot => $state.composableBuilder(
      column: $state.table.remoteRoot,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get inviteCode => $state.composableBuilder(
      column: $state.table.inviteCode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSyncAt => $state.composableBuilder(
      column: $state.table.lastSyncAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  required String id,
  required GameType gameType,
  Value<String?> locationId,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
  Value<String?> winnerId,
  required String settingsJson,
  Value<bool> isCanceled,
  Value<String> source,
  Value<String?> leagueId,
  Value<String?> remoteId,
  Value<int> rowid,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<String> id,
  Value<GameType> gameType,
  Value<String?> locationId,
  Value<DateTime> createdAt,
  Value<DateTime?> finishedAt,
  Value<String?> winnerId,
  Value<String> settingsJson,
  Value<bool> isCanceled,
  Value<String> source,
  Value<String?> leagueId,
  Value<String?> remoteId,
  Value<int> rowid,
});

class $$MatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchesTable,
    Matche,
    $$MatchesTableFilterComposer,
    $$MatchesTableOrderingComposer,
    $$MatchesTableCreateCompanionBuilder,
    $$MatchesTableUpdateCompanionBuilder> {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MatchesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MatchesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<GameType> gameType = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> winnerId = const Value.absent(),
            Value<String> settingsJson = const Value.absent(),
            Value<bool> isCanceled = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> leagueId = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesCompanion(
            id: id,
            gameType: gameType,
            locationId: locationId,
            createdAt: createdAt,
            finishedAt: finishedAt,
            winnerId: winnerId,
            settingsJson: settingsJson,
            isCanceled: isCanceled,
            source: source,
            leagueId: leagueId,
            remoteId: remoteId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required GameType gameType,
            Value<String?> locationId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> finishedAt = const Value.absent(),
            Value<String?> winnerId = const Value.absent(),
            required String settingsJson,
            Value<bool> isCanceled = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> leagueId = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesCompanion.insert(
            id: id,
            gameType: gameType,
            locationId: locationId,
            createdAt: createdAt,
            finishedAt: finishedAt,
            winnerId: winnerId,
            settingsJson: settingsJson,
            isCanceled: isCanceled,
            source: source,
            leagueId: leagueId,
            remoteId: remoteId,
            rowid: rowid,
          ),
        ));
}

class $$MatchesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GameType, GameType, String> get gameType =>
      $state.composableBuilder(
          column: $state.table.gameType,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get finishedAt => $state.composableBuilder(
      column: $state.table.finishedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get settingsJson => $state.composableBuilder(
      column: $state.table.settingsJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCanceled => $state.composableBuilder(
      column: $state.table.isCanceled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$LocationsTableFilterComposer get locationId {
    final $$LocationsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $state.db.locations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$LocationsTableFilterComposer(ComposerState(
                $state.db, $state.db.locations, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableFilterComposer get winnerId {
    final $$PlayersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.winnerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$PlayersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }

  $$LeaguesTableFilterComposer get leagueId {
    final $$LeaguesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.leagueId,
        referencedTable: $state.db.leagues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$LeaguesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.leagues, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter matchPlayersRefs(
      ComposableFilter Function($$MatchPlayersTableFilterComposer f) f) {
    final $$MatchPlayersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.matchPlayers,
        getReferencedColumn: (t) => t.matchId,
        builder: (joinBuilder, parentComposers) =>
            $$MatchPlayersTableFilterComposer(ComposerState($state.db,
                $state.db.matchPlayers, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter turnsRefs(
      ComposableFilter Function($$TurnsTableFilterComposer f) f) {
    final $$TurnsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.turns,
        getReferencedColumn: (t) => t.matchId,
        builder: (joinBuilder, parentComposers) => $$TurnsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.turns, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$MatchesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get gameType => $state.composableBuilder(
      column: $state.table.gameType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get finishedAt => $state.composableBuilder(
      column: $state.table.finishedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get settingsJson => $state.composableBuilder(
      column: $state.table.settingsJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCanceled => $state.composableBuilder(
      column: $state.table.isCanceled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get source => $state.composableBuilder(
      column: $state.table.source,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get remoteId => $state.composableBuilder(
      column: $state.table.remoteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$LocationsTableOrderingComposer get locationId {
    final $$LocationsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.locationId,
        referencedTable: $state.db.locations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$LocationsTableOrderingComposer(ComposerState(
                $state.db, $state.db.locations, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableOrderingComposer get winnerId {
    final $$PlayersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.winnerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PlayersTableOrderingComposer(ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }

  $$LeaguesTableOrderingComposer get leagueId {
    final $$LeaguesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.leagueId,
        referencedTable: $state.db.leagues,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$LeaguesTableOrderingComposer(ComposerState(
                $state.db, $state.db.leagues, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$MatchPlayersTableCreateCompanionBuilder = MatchPlayersCompanion
    Function({
  required String matchId,
  required String playerId,
  required int playerOrder,
  Value<int> rowid,
});
typedef $$MatchPlayersTableUpdateCompanionBuilder = MatchPlayersCompanion
    Function({
  Value<String> matchId,
  Value<String> playerId,
  Value<int> playerOrder,
  Value<int> rowid,
});

class $$MatchPlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchPlayersTable,
    MatchPlayer,
    $$MatchPlayersTableFilterComposer,
    $$MatchPlayersTableOrderingComposer,
    $$MatchPlayersTableCreateCompanionBuilder,
    $$MatchPlayersTableUpdateCompanionBuilder> {
  $$MatchPlayersTableTableManager(_$AppDatabase db, $MatchPlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MatchPlayersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MatchPlayersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> matchId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<int> playerOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchPlayersCompanion(
            matchId: matchId,
            playerId: playerId,
            playerOrder: playerOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String matchId,
            required String playerId,
            required int playerOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchPlayersCompanion.insert(
            matchId: matchId,
            playerId: playerId,
            playerOrder: playerOrder,
            rowid: rowid,
          ),
        ));
}

class $$MatchPlayersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableFilterComposer(super.$state);
  ColumnFilters<int> get playerOrder => $state.composableBuilder(
      column: $state.table.playerOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$MatchesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$PlayersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MatchPlayersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MatchPlayersTable> {
  $$MatchPlayersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get playerOrder => $state.composableBuilder(
      column: $state.table.playerOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MatchesTableOrderingComposer(ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PlayersTableOrderingComposer(ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$TurnsTableCreateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  required String matchId,
  required String playerId,
  required int legIndex,
  required int setIndex,
  required int roundIndex,
  required List<Dart> darts,
  Value<int?> score,
  Value<int?> dartsThrown,
  Value<int?> startingScore,
  Value<DateTime> createdAt,
});
typedef $$TurnsTableUpdateCompanionBuilder = TurnsCompanion Function({
  Value<int> id,
  Value<String> matchId,
  Value<String> playerId,
  Value<int> legIndex,
  Value<int> setIndex,
  Value<int> roundIndex,
  Value<List<Dart>> darts,
  Value<int?> score,
  Value<int?> dartsThrown,
  Value<int?> startingScore,
  Value<DateTime> createdAt,
});

class $$TurnsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TurnsTable,
    Turn,
    $$TurnsTableFilterComposer,
    $$TurnsTableOrderingComposer,
    $$TurnsTableCreateCompanionBuilder,
    $$TurnsTableUpdateCompanionBuilder> {
  $$TurnsTableTableManager(_$AppDatabase db, $TurnsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TurnsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TurnsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<int> legIndex = const Value.absent(),
            Value<int> setIndex = const Value.absent(),
            Value<int> roundIndex = const Value.absent(),
            Value<List<Dart>> darts = const Value.absent(),
            Value<int?> score = const Value.absent(),
            Value<int?> dartsThrown = const Value.absent(),
            Value<int?> startingScore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TurnsCompanion(
            id: id,
            matchId: matchId,
            playerId: playerId,
            legIndex: legIndex,
            setIndex: setIndex,
            roundIndex: roundIndex,
            darts: darts,
            score: score,
            dartsThrown: dartsThrown,
            startingScore: startingScore,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String matchId,
            required String playerId,
            required int legIndex,
            required int setIndex,
            required int roundIndex,
            required List<Dart> darts,
            Value<int?> score = const Value.absent(),
            Value<int?> dartsThrown = const Value.absent(),
            Value<int?> startingScore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TurnsCompanion.insert(
            id: id,
            matchId: matchId,
            playerId: playerId,
            legIndex: legIndex,
            setIndex: setIndex,
            roundIndex: roundIndex,
            darts: darts,
            score: score,
            dartsThrown: dartsThrown,
            startingScore: startingScore,
            createdAt: createdAt,
          ),
        ));
}

class $$TurnsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get legIndex => $state.composableBuilder(
      column: $state.table.legIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get setIndex => $state.composableBuilder(
      column: $state.table.setIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get roundIndex => $state.composableBuilder(
      column: $state.table.roundIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<Dart>, List<Dart>, String> get darts =>
      $state.composableBuilder(
          column: $state.table.darts,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dartsThrown => $state.composableBuilder(
      column: $state.table.dartsThrown,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startingScore => $state.composableBuilder(
      column: $state.table.startingScore,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$MatchesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$PlayersTableFilterComposer(
            ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TurnsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TurnsTable> {
  $$TurnsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get legIndex => $state.composableBuilder(
      column: $state.table.legIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get setIndex => $state.composableBuilder(
      column: $state.table.setIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get roundIndex => $state.composableBuilder(
      column: $state.table.roundIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get darts => $state.composableBuilder(
      column: $state.table.darts,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get score => $state.composableBuilder(
      column: $state.table.score,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dartsThrown => $state.composableBuilder(
      column: $state.table.dartsThrown,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startingScore => $state.composableBuilder(
      column: $state.table.startingScore,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.matchId,
        referencedTable: $state.db.matches,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$MatchesTableOrderingComposer(ComposerState(
                $state.db, $state.db.matches, joinBuilder, parentComposers)));
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playerId,
        referencedTable: $state.db.players,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$PlayersTableOrderingComposer(ComposerState(
                $state.db, $state.db.players, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$LeaguesTableTableManager get leagues =>
      $$LeaguesTableTableManager(_db, _db.leagues);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$MatchPlayersTableTableManager get matchPlayers =>
      $$MatchPlayersTableTableManager(_db, _db.matchPlayers);
  $$TurnsTableTableManager get turns =>
      $$TurnsTableTableManager(_db, _db.turns);
}
