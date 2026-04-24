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

class DailyMemos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStartDate => dateTime()();
  IntColumn get weekday => integer()();
  TextColumn get memoText => text()();
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
  tables: [Categories, ItemMasters, WeeklyLists, WeeklyListItems, DailyMemos, RecipeGroups],
)
class AppDatabase extends _$AppDatabase {
  static const Map<String, List<String>> _initialCatalog = {
    '野菜': [
      'キャベツ',
      'レタス',
      'トマト',
      'きゅうり',
      'にんじん',
      '玉ねぎ',
      'じゃがいも',
      'ほうれん草',
      'ブロッコリー',
      'ピーマン',
      'なす',
      '大根',
      '白菜',
      'かぼちゃ',
      'アスパラガス',
      'しいたけ',
      'しめじ',
      'えのき',
      'まいたけ',
      'エリンギ',
      'パプリカ',
      'ズッキーニ',
    ],
    '果物': [
      'りんご',
      'バナナ',
      'みかん',
      'いちご',
      'ぶどう',
      'キウイ',
      'パイナップル',
      '桃',
      '梨',
      'さくらんぼ',
    ],
    '肉': [
      '牛肉',
      '豚肉',
      '鶏むね肉',
      '鶏もも肉',
      'ひき肉',
      'ベーコン',
      'ハム',
      'ソーセージ',
      'ラム肉',
      '合いびき肉',
      '鶏ひき',
    ],
    '魚介': [
      '鮭',
      'サバ',
      'マグロ',
      'イワシ',
      'アジ',
      'エビ',
      'カニ',
      'ホタテ',
      'イカ',
      'タコ',
    ],
    '乳製品': [
      '牛乳',
      'ヨーグルト',
      'チーズ',
      'バター',
      '生クリーム',
      'カッテージチーズ',
      'アイスクリーム',
      '飲むヨーグルト',
    ],
    '穀類・主食': [
      '白米',
      '玄米',
      '食パン',
      'うどん',
      'そば',
      'パスタ',
      'シリアル',
      'オートミール',
    ],
    '飲料': [
      '水',
      '緑茶',
      'ウーロン茶',
      'コーヒー',
      '紅茶',
      'オレンジジュース',
      'コーラ',
      'スポーツドリンク',
    ],
    'お菓子': [
      'ポテトチップス',
      'チョコレート',
      'クッキー',
      'ビスケット',
      'キャンディ',
      'ガム',
      'せんべい',
      'プリン',
    ],
    '冷凍食品': [
      '冷凍餃子',
      '冷凍チャーハン',
      '冷凍うどん',
      '冷凍ピザ',
      '冷凍コロッケ',
      '冷凍からあげ',
      '冷凍野菜ミックス',
    ],
    '調味料': [
      '醤油',
      '味噌',
      '砂糖',
      '塩',
      '酢',
      'マヨネーズ',
      'オイスターソース',
      '油',
      'ごま油',
    ],
    'ベーカリー': [
      'クロワッサン',
      'ロールパン',
      'フランスパン',
      'デニッシュ',
      'あんパン',
      'メロンパン',
      'カレーパン',
      '食パン（全粒粉）',
      'ベーグル',
      'マフィン',
    ],
    '大豆製品・発酵食品': [
      '豆腐',
      '納豆',
      'キムチ',
    ],
  };

  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
      if (from < 3) {
        await migrator.createTable(dailyMemos);
      }
    },
    beforeOpen: (details) async {
      await _seedInitialCatalogIfNeeded();
    },
  );

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.data['name'] == columnName);
  }

  Future<void> _seedInitialCatalogIfNeeded() async {
    final hasCategories = await (select(categories)..limit(1)).getSingleOrNull();
    if (hasCategories != null) {
      return;
    }

    for (final entry in _initialCatalog.entries) {
      final categoryIndex = _initialCatalog.keys.toList().indexOf(entry.key);
      final category = await into(categories).insertReturning(
        CategoriesCompanion.insert(
          name: entry.key,
          sortOrder: Value(categoryIndex),
        ),
      );

      await batch((batch) {
        for (final itemName in entry.value) {
          batch.insert(
            itemMasters,
            ItemMastersCompanion.insert(
              name: itemName,
              categoryId: Value(category.id),
            ),
          );
        }
      });
    }
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
