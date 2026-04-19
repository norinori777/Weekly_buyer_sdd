import 'package:flutter/material.dart';

class SettingsDestination extends StatelessWidget {
  const SettingsDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '買い物の見やすさを調整する設定画面です。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('カテゴリの並び順'),
              subtitle: const Text('商品を見やすい順に並べ替えます。'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('カテゴリと商品'),
              subtitle: const Text('カテゴリや商品マスタの管理へ進みます。'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
