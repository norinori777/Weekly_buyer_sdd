import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import '../features/weekly_shopping_list/domain/weekly_shopping_models.dart';
import 'app_database.dart';

final appTitleProvider = Provider<String>((ref) => 'Weekly Buyer');

final appDatabaseProvider = Provider<AppDatabase>((ref) {
	final database = AppDatabase();
	ref.onDispose(database.close);
	return database;
});

final weeklyShoppingRepositoryProvider = Provider<WeeklyShoppingRepository>((ref) {
	return WeeklyShoppingRepository(ref.watch(appDatabaseProvider));
});

final weeklyShoppingSnapshotProvider =
		FutureProvider.family<WeeklyShoppingSnapshot, DateTime>((ref, referenceDate) {
	return ref.watch(weeklyShoppingRepositoryProvider).loadWeek(referenceDate);
});