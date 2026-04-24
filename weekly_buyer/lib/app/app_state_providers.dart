import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import '../features/weekly_shopping_list/domain/weekly_shopping_models.dart';
import 'app_database.dart';

final appTitleProvider = Provider<String>((ref) => 'Weekly Buyer');

enum MainShellDestination { purchaseList, itemAdd, settings }

class ItemAddDraft {
	const ItemAddDraft({
		this.name = '',
		this.quantityText = '1',
		this.section = ShoppingSection.morning,
		this.selectedCandidateId,
		this.categoryId,
	});

	final String name;
	final String quantityText;
	final ShoppingSection section;
	final int? selectedCandidateId;
	final int? categoryId;

	ItemAddDraft copyWith({
		String? name,
		String? quantityText,
		ShoppingSection? section,
		int? selectedCandidateId,
		int? categoryId,
	}) {
		return ItemAddDraft(
			name: name ?? this.name,
			quantityText: quantityText ?? this.quantityText,
			section: section ?? this.section,
			selectedCandidateId: selectedCandidateId ?? this.selectedCandidateId,
			categoryId: categoryId ?? this.categoryId,
		);
	}
}

class MealMenuDraftState {
	const MealMenuDraftState({this.textBySection = const {}});

	final Map<MealSection, String> textBySection;

	String textFor(MealSection section) {
		return textBySection[section] ?? '';
	}

	MealMenuDraftState copyWithText(MealSection section, String text) {
		return MealMenuDraftState(
			textBySection: {
				...textBySection,
				section: text,
			},
		);
	}

	MealMenuDraftState clearText(MealSection section) {
		final next = Map<MealSection, String>.from(textBySection)..remove(section);
		return MealMenuDraftState(textBySection: next);
	}
}

final mainShellDestinationProvider = StateProvider<MainShellDestination>((ref) {
	return MainShellDestination.purchaseList;
});

final previousShoppingDestinationProvider = StateProvider<MainShellDestination>((ref) {
	return MainShellDestination.purchaseList;
});

final selectedWeekDateProvider = StateProvider<DateTime>((ref) {
	return startOfNextWeek(DateTime.now());
});

final itemAddDraftProvider = StateProvider<ItemAddDraft>((ref) {
	return const ItemAddDraft();
});

final mealMenuDraftProvider = StateProvider.family<MealMenuDraftState, DateTime>((ref, referenceDate) {
	return const MealMenuDraftState();
});

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

final mealMenuSnapshotProvider = FutureProvider.family<MealMenuDaySnapshot, DateTime>((ref, referenceDate) {
	return ref.watch(weeklyShoppingRepositoryProvider).loadMealMenuSnapshot(referenceDate);
});
