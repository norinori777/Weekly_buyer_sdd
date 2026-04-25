# Data Model: SVG アイコン統一

## Overview

この機能では永続データの変更はない。アプリのブランド表示に使うアセットと、その表示方法だけを切り替える。

## Entities

### Brand Icon

アプリの見た目を代表する共通アイコン。

- `assetPath`: 表示に使う SVG アセットの場所
- `displaySize`: 画面内での表示サイズ
- `placement`: 表示する画面や領域

### SVG Asset

ブランドアイコンのベクター資産。

- `source`: `assets/weekly_buyer.svg`
- `aspectRatio`: 画像の縦横比
- `scalable`: 画面サイズに応じて拡大縮小可能

## Relationships

- Brand Icon は SVG Asset を描画した結果として表示される。
- 主要画面の AppBar は同じ Brand Icon を共有する。

## Notes

- データベースや保存モデルは変更しない。
- PNG プレースホルダ参照はこの機能で置き換える。
