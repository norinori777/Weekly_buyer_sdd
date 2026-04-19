# Quickstart: 購入リスト画面

## Prerequisites

- Flutter 開発環境
- 依存関係の取得が可能なネットワーク環境

## Setup

プロジェクトルートで依存関係を取得する。

```bash
cd weekly_buyer
flutter pub get
```

## Verify

静的解析とテストを実行する。

```bash
flutter analyze
flutter test
```

## Suggested Test Focus

- 購入リスト画面の表示
- 画面下部の `購入リスト` タブ遷移
- 画面下部の `商品追加` ボタン遷移
- 左フリックで購入済み化
- `元に戻す` での復帰
- 進捗表示の更新

## Next Step

この計画をもとに `/speckit.tasks` で実装タスクへ分解できる。