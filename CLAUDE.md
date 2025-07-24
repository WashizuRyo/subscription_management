# CLAUDE.md
このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 開発環境

これはDockerコンテナで動作するRuby on Rails 8のサブスクリプション管理アプリケーションです。

### タスクを終えたらやること
- `npx ccusage@latest` を実行して、使用量を確認
- `bin/rubocop --auto-correct` を実行して、コードの自動修正
- `docker compose exec app bin/rails spec`を実行して、テストを実行

エラーが発生した場合は，エラーが解消されるまで修正を繰り返してください。

### よく使用するコマンド

**Dockerを使った開発:**
- `make up` - 全コンテナを起動
- `make up-d` - バックグラウンドでコンテナを起動
- `make down` - 全コンテナを停止
- `make build` - Dockerイメージをビルド
- `make restart` - コンテナを再起動

**データベース操作:**
- `make migrate` - データベースマイグレーションを実行
- `make seed` - シードデータを投入
- `make setup` - データベースの作成、マイグレーション、シード投入

**テスト:**
- `make run-spec` - RSpecテストスイートを実行
- テストは`spec/`ディレクトリに配置され、RSpec、FactoryBot、Capybaraを使用

**開発ツール:**
- `make console` - Railsコンソールを起動
- `make logs` - コンテナのログを表示
- `make ps` - 実行中のコンテナ一覧を表示

### アーキテクチャ概要

**主要モデル:**
- `User` - BCryptを使用したユーザー認証
- `Subscription` - ステータスenum（active, canceled, expired, trial）を持つメインエンティティ
- `Payment` - サブスクリプションに紐づく支払い記録
- `PaymentMethod` - ユーザーの支払い方法
- `Tag` - `SubscriptionTag`を介した多対多関係のカテゴリ分類システム

**主要機能:**
- サブスクリプション請求サイクル管理（月次、年次、週次）
- `DailyBillingJob`バックグラウンドジョブによる自動請求
- `SearchSubscriptionForm`による検索機能
- タグベースのカテゴリ分類
- 請求サマリー付きダッシュボード
- 月額予算設定・使用率可視化機能

**アプリケーション構造:**
- コントローラーはusersの下にネストされたルートでRESTfulパターンに従う
- 複雑な検索ロジック用のフォームオブジェクト
- Solid Queueを使用したバックグラウンドジョブ
- Bootstrap 5 + Sassによるスタイリング
- Hotwire（Turbo + Stimulus）による強化されたUX

**データベース:**
- 本番環境でPostgreSQLを使用（`pg` gem経由）
- 開発/テスト環境ではSQLite3
- サブスクリプションステータス用のenum
- 請求計算用の複雑なスコープ

**認証:**
- BCryptを使用したカスタムセッションベース認証
- `SessionsHelper`のヘルパーメソッド
- 認可用のbefore actionフィルター

### 主要なビジネスロジック

**請求システム:**
- `billing_day_of_month`で次回請求日を保存
- `DailyBillingJob`が毎日の請求を自動処理
- 各請求サイクルで支払い記録を作成
- サブスクリプションサイクルに基づいて請求日が進む

**検索・フィルタリング:**
- `SearchSubscriptionForm`が複雑なサブスクリプションフィルタリングを処理
- テキスト、日付、多列ソートをサポート
- will_paginate gemによるページネーション

**月額予算機能:**
- Userモデルの`monthly_budget`カラムで予算上限を管理
- `monthly_subscription_total`メソッドでアクティブなサブスクの月額合計を計算
- `budget_usage_percentage`メソッドで予算使用率を算出
- `budget_remaining`メソッドで残り予算（または超過額）を計算
- ダッシュボードで使用率をプログレスバーで可視化（緑50%未満/黄50-80%/赤80%超）
- ユーザー設定画面で予算の設定・更新が可能

### 開発メモ

- アプリケーションは日本語ローカライゼーション（`ja.yml`）を使用
- `rails-erd` gemによるERD生成が利用可能
- コード品質ツール：RuboCop、Standard、Brakeman
- 開発環境で`hotwire-livereload`によるライブリロード