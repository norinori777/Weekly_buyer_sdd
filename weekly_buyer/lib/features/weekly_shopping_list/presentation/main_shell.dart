import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import 'item_add_destination.dart';
import 'purchase_list_destination.dart';
import 'settings_destination.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(mainShellDestinationProvider);
    final previousShoppingDestination = ref.watch(previousShoppingDestinationProvider);

    return PopScope(
      canPop: destination != MainShellDestination.settings,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || destination != MainShellDestination.settings) {
          return;
        }
        ref.read(mainShellDestinationProvider.notifier).state = previousShoppingDestination;
      },
      child: Scaffold(
        body: IndexedStack(
          index: destination.index,
          children: const [
            PurchaseListDestination(),
            ItemAddDestination(),
            SettingsDestination(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: destination.index,
          onTap: (index) {
            final nextDestination = MainShellDestination.values[index];
            if (nextDestination == MainShellDestination.settings) {
              if (destination != MainShellDestination.settings) {
                ref.read(previousShoppingDestinationProvider.notifier).state = destination;
              }
            } else {
              ref.read(previousShoppingDestinationProvider.notifier).state = nextDestination;
            }
            ref.read(mainShellDestinationProvider.notifier).state = nextDestination;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_outlined),
              label: '購入リスト',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: '商品追加',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
