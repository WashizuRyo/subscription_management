.PHONY: up down build restart test seed migrate setup console logs ps

# コンテナの起動
up:
	docker compose up

# バックグラウンドでコンテナを起動
up-d:
	docker compose up -d

# コンテナの停止
down:
	docker compose down

# ビルド
build:
	docker compose build

# 再起動
restart:
	docker compose restart

# RSpec実行（指定されたもの）
run-spec:
	docker compose exec app bin/rails spec

# シードデータの投入
seed:
	docker compose run --rm app bin/rails db:seed

# マイグレーション実行
migrate:
	docker compose run --rm app bin/rails db:migrate

# DBセットアップ（作成・マイグレーション・シード）
setup:
	docker compose run --rm app bin/rails db:setup

# Railsコンソール起動
console:
	docker compose run --rm app bin/rails console

# コンテナのログ表示
logs:
	docker compose logs -f

# 実行中のコンテナ一覧
ps:
	docker compose ps