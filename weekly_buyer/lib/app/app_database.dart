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
  TextColumn get hiragana => text().nullable()();
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

class DailyMealMenus extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStartDate => dateTime()();
  IntColumn get weekday => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class MealMenuEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyMealMenuId => integer().references(
    DailyMealMenus,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get mealSection => text()();
  TextColumn get menuText => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
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
  tables: [
    Categories,
    ItemMasters,
    WeeklyLists,
    WeeklyListItems,
    DailyMemos,
    DailyMealMenus,
    MealMenuEntries,
    RecipeGroups,
  ],
)
class AppDatabase extends _$AppDatabase {
  static const List<_InitialCategorySeed> _initialCatalog = [
    _InitialCategorySeed(
      name: '野菜',
      items: [
        _InitialItemSeed(name: 'キャベツ', hiragana: 'きゃべつ'),
        _InitialItemSeed(name: 'レタス', hiragana: 'れたす'),
        _InitialItemSeed(name: 'トマト', hiragana: 'とまと'),
        _InitialItemSeed(name: 'きゅうり', hiragana: 'きゅうり'),
        _InitialItemSeed(name: 'にんじん', hiragana: 'にんじん'),
        _InitialItemSeed(name: '玉ねぎ', hiragana: 'たまねぎ'),
        _InitialItemSeed(name: 'じゃがいも', hiragana: 'じゃがいも'),
        _InitialItemSeed(name: 'ほうれん草', hiragana: 'ほうれんそう'),
        _InitialItemSeed(name: 'ブロッコリー', hiragana: 'ぶろっこりー'),
        _InitialItemSeed(name: 'ピーマン', hiragana: 'ぴーまん'),
        _InitialItemSeed(name: 'なす', hiragana: 'なす'),
        _InitialItemSeed(name: '大根', hiragana: 'だいこん'),
        _InitialItemSeed(name: '白菜', hiragana: 'はくさい'),
        _InitialItemSeed(name: 'かぼちゃ', hiragana: 'かぼちゃ'),
        _InitialItemSeed(name: 'アスパラガス', hiragana: 'あすぱらがす'),
        _InitialItemSeed(name: 'しいたけ', hiragana: 'しいたけ'),
        _InitialItemSeed(name: 'しめじ', hiragana: 'しめじ'),
        _InitialItemSeed(name: 'えのき', hiragana: 'えのき'),
        _InitialItemSeed(name: 'まいたけ', hiragana: 'まいたけ'),
        _InitialItemSeed(name: 'エリンギ', hiragana: 'えりんぎ'),
        _InitialItemSeed(name: 'パプリカ', hiragana: 'ぱぷりか'),
        _InitialItemSeed(name: 'ズッキーニ', hiragana: 'ずっきーに'),
        _InitialItemSeed(name: '豆苗', hiragana: 'とうみょう'),
        _InitialItemSeed(name: '水菜', hiragana: 'みずな'),
        _InitialItemSeed(name: 'プチトマト', hiragana: 'ぷちとまと'),
      ],
    ),
    _InitialCategorySeed(
      name: '果物',
      items: [
        _InitialItemSeed(name: 'りんご', hiragana: 'りんご'),
        _InitialItemSeed(name: 'バナナ', hiragana: 'ばなな'),
        _InitialItemSeed(name: 'みかん', hiragana: 'みかん'),
        _InitialItemSeed(name: 'いちご', hiragana: 'いちご'),
        _InitialItemSeed(name: 'ぶどう', hiragana: 'ぶどう'),
        _InitialItemSeed(name: 'キウイ', hiragana: 'きうい'),
        _InitialItemSeed(name: 'パイナップル', hiragana: 'ぱいなっぷる'),
        _InitialItemSeed(name: '桃', hiragana: 'もも'),
        _InitialItemSeed(name: '梨', hiragana: 'なし'),
        _InitialItemSeed(name: 'さくらんぼ', hiragana: 'さくらんぼ'),
      ],
    ),
    _InitialCategorySeed(
      name: '肉',
      items: [
        _InitialItemSeed(name: '牛肉', hiragana: 'ぎゅうにく'),
        _InitialItemSeed(name: '豚肉', hiragana: 'ぶたにく'),
        _InitialItemSeed(name: '鶏むね肉', hiragana: 'とりむねにく'),
        _InitialItemSeed(name: '鶏もも肉', hiragana: 'とりももにく'),
        _InitialItemSeed(name: 'ひき肉', hiragana: 'ひきにく'),
        _InitialItemSeed(name: 'ベーコン', hiragana: 'べーこん'),
        _InitialItemSeed(name: 'ハム', hiragana: 'はむ'),
        _InitialItemSeed(name: 'ソーセージ', hiragana: 'そーせーじ'),
        _InitialItemSeed(name: 'ラム肉', hiragana: 'らむにく'),
        _InitialItemSeed(name: '合いびき肉', hiragana: 'あいびきにく'),
        _InitialItemSeed(name: '鶏ひき', hiragana: 'とりひき'),
      ],
    ),
    _InitialCategorySeed(
      name: '魚介',
      items: [
        _InitialItemSeed(name: '鮭', hiragana: 'さけ'),
        _InitialItemSeed(name: 'サバ', hiragana: 'さば'),
        _InitialItemSeed(name: 'マグロ', hiragana: 'まぐろ'),
        _InitialItemSeed(name: 'イワシ', hiragana: 'いわし'),
        _InitialItemSeed(name: 'アジ', hiragana: 'あじ'),
        _InitialItemSeed(name: 'エビ', hiragana: 'えび'),
        _InitialItemSeed(name: 'カニ', hiragana: 'かに'),
        _InitialItemSeed(name: 'ホタテ', hiragana: 'ほたて'),
        _InitialItemSeed(name: 'イカ', hiragana: 'いか'),
        _InitialItemSeed(name: 'タコ', hiragana: 'たこ'),
      ],
    ),
    _InitialCategorySeed(
      name: '卵・乳製品',
      items: [
        _InitialItemSeed(name: '卵', hiragana: 'たまご'),
        _InitialItemSeed(name: '牛乳', hiragana: 'ぎゅうにゅう'),
        _InitialItemSeed(name: 'ヨーグルト', hiragana: 'よーぐると'),
        _InitialItemSeed(name: 'チーズ', hiragana: 'ちーず'),
        _InitialItemSeed(name: 'バター', hiragana: 'ばたー'),
        _InitialItemSeed(name: '生クリーム', hiragana: 'なまくりーむ'),
        _InitialItemSeed(name: 'カッテージチーズ', hiragana: 'かってーじちーず'),
        _InitialItemSeed(name: 'アイスクリーム', hiragana: 'あいすくりーむ'),
        _InitialItemSeed(name: '飲むヨーグルト', hiragana: 'のむよーぐると'),
      ],
    ),
    _InitialCategorySeed(
      name: '穀類・主食',
      items: [
        _InitialItemSeed(name: '白米', hiragana: 'はくまい'),
        _InitialItemSeed(name: '玄米', hiragana: 'げんまい'),
        _InitialItemSeed(name: '食パン', hiragana: 'しょくぱん'),
        _InitialItemSeed(name: 'うどん', hiragana: 'うどん'),
        _InitialItemSeed(name: 'そば', hiragana: 'そば'),
        _InitialItemSeed(name: 'パスタ', hiragana: 'ぱすた'),
        _InitialItemSeed(name: 'シリアル', hiragana: 'しりある'),
        _InitialItemSeed(name: 'オートミール', hiragana: 'おーとみーる'),
      ],
    ),
    _InitialCategorySeed(
      name: '飲料',
      items: [
        _InitialItemSeed(name: '水', hiragana: 'みず'),
        _InitialItemSeed(name: '緑茶', hiragana: 'りょくちゃ'),
        _InitialItemSeed(name: 'ウーロン茶', hiragana: 'うーろんちゃ'),
        _InitialItemSeed(name: 'コーヒー', hiragana: 'こーひー'),
        _InitialItemSeed(name: '紅茶', hiragana: 'こうちゃ'),
        _InitialItemSeed(name: 'オレンジジュース', hiragana: 'おれんじじゅーす'),
        _InitialItemSeed(name: 'コーラ', hiragana: 'こーら'),
        _InitialItemSeed(name: 'スポーツドリンク', hiragana: 'すぽーつどりんく'),
      ],
    ),
    _InitialCategorySeed(
      name: 'お菓子',
      items: [
        _InitialItemSeed(name: 'ポテトチップス', hiragana: 'ぽてとちっぷす'),
        _InitialItemSeed(name: 'チョコレート', hiragana: 'ちょこれーと'),
        _InitialItemSeed(name: 'クッキー', hiragana: 'くっきー'),
        _InitialItemSeed(name: 'ビスケット', hiragana: 'びすけっと'),
        _InitialItemSeed(name: 'キャンディ', hiragana: 'きゃんでぃ'),
        _InitialItemSeed(name: 'ガム', hiragana: 'がむ'),
        _InitialItemSeed(name: 'せんべい', hiragana: 'せんべい'),
        _InitialItemSeed(name: 'プリン', hiragana: 'ぷりん'),
      ],
    ),
    _InitialCategorySeed(
      name: '冷凍食品',
      items: [
        _InitialItemSeed(name: '冷凍餃子', hiragana: 'れいとうぎょうざ'),
        _InitialItemSeed(name: '冷凍チャーハン', hiragana: 'れいとうちゃーはん'),
        _InitialItemSeed(name: '冷凍うどん', hiragana: 'れいとううどん'),
        _InitialItemSeed(name: '冷凍ピザ', hiragana: 'れいとうぴざ'),
        _InitialItemSeed(name: '冷凍コロッケ', hiragana: 'れいとうころっけ'),
        _InitialItemSeed(name: '冷凍からあげ', hiragana: 'れいとうからあげ'),
        _InitialItemSeed(name: '冷凍野菜ミックス', hiragana: 'れいとうやさいみっくす'),
      ],
    ),
    _InitialCategorySeed(
      name: '調味料',
      items: [
        _InitialItemSeed(name: '醤油', hiragana: 'しょうゆ'),
        _InitialItemSeed(name: '味噌', hiragana: 'みそ'),
        _InitialItemSeed(name: '砂糖', hiragana: 'さとう'),
        _InitialItemSeed(name: '塩', hiragana: 'しお'),
        _InitialItemSeed(name: '酢', hiragana: 'す'),
        _InitialItemSeed(name: 'マヨネーズ', hiragana: 'まよねーず'),
        _InitialItemSeed(name: 'オイスターソース', hiragana: 'おいすたーそーす'),
        _InitialItemSeed(name: '油', hiragana: 'あぶら'),
        _InitialItemSeed(name: 'ごま油', hiragana: 'ごまあぶら'),
      ],
    ),
    _InitialCategorySeed(
      name: 'ベーカリー',
      items: [
        _InitialItemSeed(name: 'クロワッサン', hiragana: 'くろわっさん'),
        _InitialItemSeed(name: 'ロールパン', hiragana: 'ろーるぱん'),
        _InitialItemSeed(name: 'フランスパン', hiragana: 'ふらんすぱん'),
        _InitialItemSeed(name: 'デニッシュ', hiragana: 'でにっしゅ'),
        _InitialItemSeed(name: 'あんパン', hiragana: 'あんぱん'),
        _InitialItemSeed(name: 'メロンパン', hiragana: 'めろんぱん'),
        _InitialItemSeed(name: 'カレーパン', hiragana: 'かれーぱん'),
        _InitialItemSeed(name: '食パン（全粒粉）', hiragana: 'しょくぱんぜんりゅうふん'),
        _InitialItemSeed(name: 'ベーグル', hiragana: 'べーぐる'),
        _InitialItemSeed(name: 'マフィン', hiragana: 'まふぃん'),
      ],
    ),
    _InitialCategorySeed(
      name: '大豆製品・発酵食品',
      items: [
        _InitialItemSeed(name: '豆腐', hiragana: 'とうふ'),
        _InitialItemSeed(name: '納豆', hiragana: 'なっとう'),
        _InitialItemSeed(name: 'キムチ', hiragana: 'きむち'),
      ],
    ),
  ];

  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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
      if (from < 4) {
        await migrator.createTable(dailyMealMenus);
        await migrator.createTable(mealMenuEntries);
      }
      if (from < 5) {
        if (!await _hasColumn('item_masters', 'hiragana')) {
          await migrator.addColumn(itemMasters, itemMasters.hiragana);
        }
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
    await transaction(() async {
      for (var categoryIndex = 0; categoryIndex < _initialCatalog.length; categoryIndex++) {
        final categorySeed = _initialCatalog[categoryIndex];
        final categoryId = await _ensureSeedCategory(categorySeed, categoryIndex);
        if (categoryId == null) {
          continue;
        }

        for (final itemSeed in categorySeed.items) {
          await _ensureSeedItem(categoryId, itemSeed);
        }
      }
    });
  }

  Future<int?> _ensureSeedCategory(
    _InitialCategorySeed categorySeed,
    int sortOrder,
  ) async {
    final existing = await (select(categories)
          ..where((table) => table.name.equals(categorySeed.name)))
        .getSingleOrNull();
    if (existing != null) {
      return existing.isActive ? existing.id : null;
    }

    final inserted = await into(categories).insertReturning(
      CategoriesCompanion.insert(
        name: categorySeed.name,
        sortOrder: Value(sortOrder),
      ),
    );
    return inserted.id;
  }

  Future<void> _ensureSeedItem(int categoryId, _InitialItemSeed itemSeed) async {
    final existing = await (select(itemMasters)
          ..where(
            (table) =>
                table.name.equals(itemSeed.name) & table.categoryId.equals(categoryId),
          ))
        .getSingleOrNull();

    if (existing != null) {
      if (existing.isActive &&
          (existing.hiragana == null || existing.hiragana!.trim().isEmpty) &&
          existing.hiragana != itemSeed.hiragana) {
        await (update(itemMasters)
              ..where((table) => table.id.equals(existing.id)))
            .write(
          ItemMastersCompanion(
            hiragana: Value(itemSeed.hiragana),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      return;
    }

    await into(itemMasters).insert(
      ItemMastersCompanion.insert(
        name: itemSeed.name,
        hiragana: Value(itemSeed.hiragana),
        categoryId: Value(categoryId),
      ),
    );
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

class _InitialCategorySeed {
  const _InitialCategorySeed({
    required this.name,
    required this.items,
  });

  final String name;
  final List<_InitialItemSeed> items;
}

class _InitialItemSeed {
  const _InitialItemSeed({
    required this.name,
    required this.hiragana,
  });

  final String name;
  final String hiragana;
}
