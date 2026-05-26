## PR タイトル(必須)

<!-- 下記のフォーマットに合わせて修正し、PRのタイトル（Subject）として使用してください -->

merge([source]->[target]): [summary]

## 今回の更新内容（レビュー者向けに必要なら記載）

- 機能の改善内容
- 不具合修正内容
- 注意事項

## 参考情報

<details>

<summary>📌 PR タイトル規約</summary>
<br>

**フォーマット**

```
merge([source]->[target]): [summary]
```

**例**

```
merge(dev->qa): auth OAuth ログイン追加
merge(qa->main): release 1.4.0
merge(feature/login-timeout->dev): ログインタイムアウト修正
```

**補足ルール**

- PR タイトルは Merge Commit の先頭行として使用されます
- PR タイトルは規約に沿って設定してください（管理・追跡をしやすくするため）
- summary は日本語 / 英語どちらでも可

</details>

<details>

<summary>📌 リリースラベルについて（この PR のマージ先が <b>main</b> の場合のみ必須）</summary>
<br>

`main` にマージする前に、以下のいずれか **1 つだけ** のラベルを付与してください。

- `AEGIS: release`  
  配信（リリース）を行う変更の場合
- `AEGIS: no-release`  
  配信（リリース）不要な変更の場合  
  （例：ドキュメント更新、CI 設定変更など）

※ `dev` や `qa` へのマージの場合は対応不要です。

</details>
