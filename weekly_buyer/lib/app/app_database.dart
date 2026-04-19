import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ItemMasters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get defaultQuantity => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WeeklyLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStart => dateTime()();
  DateTimeColumn get weekEnd => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WeeklyListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get weeklyListId =>
      integer().references(WeeklyLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get weekday => integer().withDefault(const Constant(1))();
  TextColumn get sectionName => text()();
  IntColumn get itemMasterId => integer().nullable().references(
    ItemMasters,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get itemName => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  BoolColumn get isPurchased => boolean().withDefault(const Constant(false))();
  DateTimeColumn get purchasedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class RecipeGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [Categories, ItemMasters, WeeklyLists, WeeklyListItems, RecipeGroups],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        if (!await _hasColumn('weekly_list_items', 'weekday')) {
          await migrator.addColumn(weeklyListItems, weeklyListItems.weekday);
        }
        await customStatement(
          "UPDATE weekly_list_items SET weekday = COALESCE(((CAST(strftime('%w', created_at) AS INTEGER) + 6) % 7) + 1, 1)",
        );
      }
    },
  );

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.data['name'] == columnName);
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      return driftDatabase(
        name: 'weekly_buyer',
        web: kIsWeb
            ? DriftWebOptions(
                sqlite3Wasm: Uri.parse('/sqlite3.wasm'),
                driftWorker: Uri.parse('/drift_worker.js'),
              )
            : null,
      );
    });
  }
}
