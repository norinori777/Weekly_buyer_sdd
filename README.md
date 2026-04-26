# weekly_buyer

週ごとの買い物メモと購入リストをまとめて管理する Flutter 製アプリです。

## このリポジトリについて

このリポジトリには、買い物を週単位で整理しながら使うためのアプリ本体と、その実装に関する仕様・設計ドキュメントが含まれています。

アプリ側では、購入リストの確認、商品追加画面での入力、カテゴリ設定、曜日ごとの登録、音声入力など、買い物中に必要な操作をひとつの流れで扱えるようにしています。

このアプリの開発では GitHub Spec Kit を使い、まず仕様を `specs/` 配下にまとめ、その後に `plan.md`、`tasks.md`、`checklists/` を通して実装と検証を進める流れを採っています。

## 主な開発物

- 週ごとの買い物リストを扱う共通シェルと画面遷移
- 商品追加画面と商品編集まわりの UI
- 私用メモの自動保存
- 料理メニューの個別追加・削除
- カテゴリ順やカテゴリごとの設定画面
- 音声入力を使った商品名登録
- SVG アイコンを使ったアプリアセット

## 技術構成

- Flutter
- Dart 3.11
- flutter_riverpod
- Drift / SQLite
- flutter_svg
- speech_to_text

## ディレクトリ構成

- weekly_buyer/lib/ - アプリ本体
- weekly_buyer/assets/ - 画像や SVG などのアセット
- specs/ - 機能ごとの仕様、設計、タスク、チェックリスト
- weekly_buyer/test/ - テストコード

## 開発メモ

各機能の仕様は `specs/` 配下にまとまっています。新しい実装や仕様変更を行うときは、該当する feature ディレクトリの `spec.md`、`plan.md`、`tasks.md` を確認すると追いやすいです。

## セットアップ

```bash
flutter pub get
```

## 実行

```bash
flutter run
```

## 検証

```bash
flutter analyze
flutter test
```
