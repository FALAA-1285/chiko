// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TaskCategory, String> category =
      GeneratedColumn<String>('category', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TaskCategory>($TasksTable.$convertercategory);
  static const VerificationMeta _groupNameMeta = const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName =
      GeneratedColumn<String>('group_name', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Priority, String> priority =
      GeneratedColumn<String>('priority', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Priority>($TasksTable.$converterpriority);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note =
      GeneratedColumn<String>('note', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startAtMeta = const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>('start_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt =
      GeneratedColumn<DateTime>('due_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>('completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, title, category, groupName, priority, note, startAt, dueAt, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta, groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta, startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(_dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: $TasksTable.$convertercategory
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      dueAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      startAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_at']),
      groupName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}group_name']),
      priority: $TasksTable.$converterpriority
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}priority'])!),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskCategory, String, String> $convertercategory =
      const EnumNameConverter<TaskCategory>(TaskCategory.values);
  static JsonTypeConverter2<Priority, String, String> $converterpriority =
      const EnumNameConverter<Priority>(Priority.values);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<TaskCategory> category;
  final Value<String?> groupName;
  final Value<Priority> priority;
  final Value<String?> note;
  final Value<DateTime?> startAt;
  final Value<DateTime> dueAt;
  final Value<DateTime?> completedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.groupName = const Value.absent(),
    this.priority = const Value.absent(),
    this.note = const Value.absent(),
    this.startAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required TaskCategory category,
    this.groupName = const Value.absent(),
    required Priority priority,
    this.note = const Value.absent(),
    this.startAt = const Value.absent(),
    required DateTime dueAt,
    this.completedAt = const Value.absent(),
  })  : title = Value(title),
        category = Value(category),
        priority = Value(priority),
        dueAt = Value(dueAt);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? groupName,
    Expression<String>? priority,
    Expression<String>? note,
    Expression<DateTime>? startAt,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (groupName != null) 'group_name': groupName,
      if (priority != null) 'priority': priority,
      if (note != null) 'note': note,
      if (startAt != null) 'start_at': startAt,
      if (dueAt != null) 'due_at': dueAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<TaskCategory>? category,
      Value<String?>? groupName,
      Value<Priority>? priority,
      Value<String?>? note,
      Value<DateTime?>? startAt,
      Value<DateTime>? dueAt,
      Value<DateTime?>? completedAt}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      groupName: groupName ?? this.groupName,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      startAt: startAt ?? this.startAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (category.present) {
      map['category'] = Variable<String>($TasksTable.$convertercategory.toSql(category.value));
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>($TasksTable.$converterpriority.toSql(priority.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('groupName: $groupName, ')
          ..write('priority: $priority, ')
          ..write('note: $note, ')
          ..write('startAt: $startAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class _$TaskInsertable implements Insertable<Task> {
  Task _object;
  _$TaskInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(_object.id),
      title: Value(_object.title),
      category: Value(_object.category),
      groupName: Value(_object.groupName),
      priority: Value(_object.priority),
      note: Value(_object.note),
      startAt: Value(_object.startAt),
      dueAt: Value(_object.dueAt),
      completedAt: Value(_object.completedAt),
    ).toColumns(false);
  }
}

extension TaskToInsertable on Task {
  _$TaskInsertable toInsertable() {
    return _$TaskInsertable(this);
  }
}

class $ScheduleEntriesTable extends ScheduleEntries with TableInfo<$ScheduleEntriesTable, ScheduleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<EventType, String> type =
      GeneratedColumn<String>('type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<EventType>($ScheduleEntriesTable.$convertertype);
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>('start_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end =
      GeneratedColumn<DateTime>('end_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>('place', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant(''));
  static const VerificationMeta _repeatWeeklyMeta = const VerificationMeta('repeatWeekly');
  @override
  late final GeneratedColumn<bool> repeatWeekly = GeneratedColumn<bool>('repeat_weekly', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("repeat_weekly" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _repeatUntilMeta = const VerificationMeta('repeatUntil');
  @override
  late final GeneratedColumn<DateTime> repeatUntil = GeneratedColumn<DateTime>('repeat_until', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, title, type, start, end, place, repeatWeekly, repeatUntil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduleEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startMeta, start.isAcceptableOrUnknown(data['start_at']!, _startMeta));
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(_endMeta, end.isAcceptableOrUnknown(data['end_at']!, _endMeta));
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('place')) {
      context.handle(_placeMeta, place.isAcceptableOrUnknown(data['place']!, _placeMeta));
    }
    if (data.containsKey('repeat_weekly')) {
      context.handle(_repeatWeeklyMeta, repeatWeekly.isAcceptableOrUnknown(data['repeat_weekly']!, _repeatWeeklyMeta));
    }
    if (data.containsKey('repeat_until')) {
      context.handle(_repeatUntilMeta, repeatUntil.isAcceptableOrUnknown(data['repeat_until']!, _repeatUntilMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      type: $ScheduleEntriesTable.$convertertype
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      start: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      end: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_at'])!,
      place: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}place'])!,
      repeatWeekly: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}repeat_weekly'])!,
      repeatUntil: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}repeat_until']),
    );
  }

  @override
  $ScheduleEntriesTable createAlias(String alias) {
    return $ScheduleEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EventType, String, String> $convertertype =
      const EnumNameConverter<EventType>(EventType.values);
}

class ScheduleEntriesCompanion extends UpdateCompanion<ScheduleEntry> {
  final Value<int> id;
  final Value<String> title;
  final Value<EventType> type;
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<String> place;
  final Value<bool> repeatWeekly;
  final Value<DateTime?> repeatUntil;
  const ScheduleEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.place = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    this.repeatUntil = const Value.absent(),
  });
  ScheduleEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required EventType type,
    required DateTime start,
    required DateTime end,
    this.place = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    this.repeatUntil = const Value.absent(),
  })  : title = Value(title),
        type = Value(type),
        start = Value(start),
        end = Value(end);
  static Insertable<ScheduleEntry> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<String>? place,
    Expression<bool>? repeatWeekly,
    Expression<DateTime>? repeatUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (start != null) 'start_at': start,
      if (end != null) 'end_at': end,
      if (place != null) 'place': place,
      if (repeatWeekly != null) 'repeat_weekly': repeatWeekly,
      if (repeatUntil != null) 'repeat_until': repeatUntil,
    });
  }

  ScheduleEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<EventType>? type,
      Value<DateTime>? start,
      Value<DateTime>? end,
      Value<String>? place,
      Value<bool>? repeatWeekly,
      Value<DateTime?>? repeatUntil}) {
    return ScheduleEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      place: place ?? this.place,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
      repeatUntil: repeatUntil ?? this.repeatUntil,
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
    if (type.present) {
      map['type'] = Variable<String>($ScheduleEntriesTable.$convertertype.toSql(type.value));
    }
    if (start.present) {
      map['start_at'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end_at'] = Variable<DateTime>(end.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (repeatWeekly.present) {
      map['repeat_weekly'] = Variable<bool>(repeatWeekly.value);
    }
    if (repeatUntil.present) {
      map['repeat_until'] = Variable<DateTime>(repeatUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('place: $place, ')
          ..write('repeatWeekly: $repeatWeekly, ')
          ..write('repeatUntil: $repeatUntil')
          ..write(')'))
        .toString();
  }
}

class _$ScheduleEntryInsertable implements Insertable<ScheduleEntry> {
  ScheduleEntry _object;
  _$ScheduleEntryInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return ScheduleEntriesCompanion(
      id: Value(_object.id),
      title: Value(_object.title),
      type: Value(_object.type),
      start: Value(_object.start),
      end: Value(_object.end),
      place: Value(_object.place),
      repeatWeekly: Value(_object.repeatWeekly),
      repeatUntil: Value(_object.repeatUntil),
    ).toColumns(false);
  }
}

extension ScheduleEntryToInsertable on ScheduleEntry {
  _$ScheduleEntryInsertable toInsertable() {
    return _$ScheduleEntryInsertable(this);
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> type =
      GeneratedColumn<String>('type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta('initialBalance');
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>('initial_balance', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
  static const VerificationMeta _colorValueMeta = const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue =
      GeneratedColumn<int>('color_value', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, type, initialBalance, colorValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
          _initialBalanceMeta, initialBalance.isAcceptableOrUnknown(data['initial_balance']!, _initialBalanceMeta));
    }
    if (data.containsKey('color_value')) {
      context.handle(_colorValueMeta, colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $AccountsTable.$convertertype
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      initialBalance: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}initial_balance'])!,
      colorValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, String, String> $convertertype =
      const EnumNameConverter<AccountType>(AccountType.values);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<int> initialBalance;
  final Value<int> colorValue;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.colorValue = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType type,
    this.initialBalance = const Value.absent(),
    required int colorValue,
  })  : name = Value(name),
        type = Value(type),
        colorValue = Value(colorValue);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? initialBalance,
    Expression<int>? colorValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (colorValue != null) 'color_value': colorValue,
    });
  }

  AccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<AccountType>? type,
      Value<int>? initialBalance,
      Value<int>? colorValue}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>($AccountsTable.$convertertype.toSql(type.value));
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }
}

class _$AccountInsertable implements Insertable<Account> {
  Account _object;
  _$AccountInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      type: Value(_object.type),
      initialBalance: Value(_object.initialBalance),
      colorValue: Value(_object.colorValue),
    ).toColumns(false);
  }
}

extension AccountToInsertable on Account {
  _$AccountInsertable toInsertable() {
    return _$AccountInsertable(this);
  }
}

class $TxnCategoriesTable extends TxnCategories with TableInfo<$TxnCategoriesTable, TxnCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TxnKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TxnKind>($TxnCategoriesTable.$converterkind);
  static const VerificationMeta _iconKeyMeta = const VerificationMeta('iconKey');
  @override
  late final GeneratedColumn<String> iconKey =
      GeneratedColumn<String>('icon_key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta = const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue =
      GeneratedColumn<int>('color_value', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _softValueMeta = const VerificationMeta('softValue');
  @override
  late final GeneratedColumn<int> softValue =
      GeneratedColumn<int>('soft_value', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, kind, iconKey, colorValue, softValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<TxnCategory> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(_iconKeyMeta, iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta));
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(_colorValueMeta, colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('soft_value')) {
      context.handle(_softValueMeta, softValue.isAcceptableOrUnknown(data['soft_value']!, _softValueMeta));
    } else if (isInserting) {
      context.missing(_softValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TxnCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TxnCategory(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: $TxnCategoriesTable.$converterkind
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
      iconKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon_key'])!,
      colorValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      softValue: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}soft_value'])!,
    );
  }

  @override
  $TxnCategoriesTable createAlias(String alias) {
    return $TxnCategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxnKind, String, String> $converterkind = const EnumNameConverter<TxnKind>(TxnKind.values);
}

class TxnCategoriesCompanion extends UpdateCompanion<TxnCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<TxnKind> kind;
  final Value<String> iconKey;
  final Value<int> colorValue;
  final Value<int> softValue;
  const TxnCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.softValue = const Value.absent(),
  });
  TxnCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required TxnKind kind,
    required String iconKey,
    required int colorValue,
    required int softValue,
  })  : name = Value(name),
        kind = Value(kind),
        iconKey = Value(iconKey),
        colorValue = Value(colorValue),
        softValue = Value(softValue);
  static Insertable<TxnCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? iconKey,
    Expression<int>? colorValue,
    Expression<int>? softValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorValue != null) 'color_value': colorValue,
      if (softValue != null) 'soft_value': softValue,
    });
  }

  TxnCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<TxnKind>? kind,
      Value<String>? iconKey,
      Value<int>? colorValue,
      Value<int>? softValue}) {
    return TxnCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      softValue: softValue ?? this.softValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>($TxnCategoriesTable.$converterkind.toSql(kind.value));
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (softValue.present) {
      map['soft_value'] = Variable<int>(softValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorValue: $colorValue, ')
          ..write('softValue: $softValue')
          ..write(')'))
        .toString();
  }
}

class _$TxnCategoryInsertable implements Insertable<TxnCategory> {
  TxnCategory _object;
  _$TxnCategoryInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return TxnCategoriesCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      kind: Value(_object.kind),
      iconKey: Value(_object.iconKey),
      colorValue: Value(_object.colorValue),
      softValue: Value(_object.softValue),
    ).toColumns(false);
  }
}

extension TxnCategoryToInsertable on TxnCategory {
  _$TxnCategoryInsertable toInsertable() {
    return _$TxnCategoryInsertable(this);
  }
}

class $TxnsTable extends Txns with TableInfo<$TxnsTable, Txn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<TxnKind, String> kind =
      GeneratedColumn<String>('kind', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TxnKind>($TxnsTable.$converterkind);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>('amount', aliasedName, false,
      check: () => ComparableExpr(amount).isBiggerThanValue(0), type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta = const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>('account_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES accounts (id) ON DELETE RESTRICT'));
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>('to_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES accounts (id) ON DELETE RESTRICT'));
  static const VerificationMeta _categoryIdMeta = const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>('category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES categories (id) ON DELETE RESTRICT'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>('note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: false, defaultValue: const Constant(''));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date =
      GeneratedColumn<DateTime>('date', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, kind, amount, accountId, toAccountId, categoryId, note, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Txn> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta, accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(_toAccountIdMeta, toAccountId.isAcceptableOrUnknown(data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(_categoryIdMeta, categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Txn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Txn(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: $TxnsTable.$converterkind
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!),
      amount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      accountId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      toAccountId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}to_account_id']),
      categoryId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $TxnsTable createAlias(String alias) {
    return $TxnsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxnKind, String, String> $converterkind = const EnumNameConverter<TxnKind>(TxnKind.values);
}

class TxnsCompanion extends UpdateCompanion<Txn> {
  final Value<int> id;
  final Value<TxnKind> kind;
  final Value<int> amount;
  final Value<int> accountId;
  final Value<int?> toAccountId;
  final Value<int?> categoryId;
  final Value<String> note;
  final Value<DateTime> date;
  const TxnsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
  });
  TxnsCompanion.insert({
    this.id = const Value.absent(),
    required TxnKind kind,
    required int amount,
    required int accountId,
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime date,
  })  : kind = Value(kind),
        amount = Value(amount),
        accountId = Value(accountId),
        date = Value(date);
  static Insertable<Txn> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? amount,
    Expression<int>? accountId,
    Expression<int>? toAccountId,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
    });
  }

  TxnsCompanion copyWith(
      {Value<int>? id,
      Value<TxnKind>? kind,
      Value<int>? amount,
      Value<int>? accountId,
      Value<int?>? toAccountId,
      Value<int?>? categoryId,
      Value<String>? note,
      Value<DateTime>? date}) {
    return TxnsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>($TxnsTable.$converterkind.toSql(kind.value));
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class _$TxnInsertable implements Insertable<Txn> {
  Txn _object;
  _$TxnInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return TxnsCompanion(
      id: Value(_object.id),
      kind: Value(_object.kind),
      amount: Value(_object.amount),
      accountId: Value(_object.accountId),
      toAccountId: Value(_object.toAccountId),
      categoryId: Value(_object.categoryId),
      note: Value(_object.note),
      date: Value(_object.date),
    ).toColumns(false);
  }
}

extension TxnToInsertable on Txn {
  _$TxnInsertable toInsertable() {
    return _$TxnInsertable(this);
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key =
      GeneratedColumn<String>('key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value =
      GeneratedColumn<String>('value', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ScheduleEntriesTable scheduleEntries = $ScheduleEntriesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TxnCategoriesTable txnCategories = $TxnCategoriesTable(this);
  late final $TxnsTable txns = $TxnsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks, scheduleEntries, accounts, txnCategories, txns, settings];
}
