# 🐱 Nekostay - 愛猫のための優しい見守りアプリ

![GitHub language count](https://img.shields.io/github/languages/count/leongswan/nekostay)
![Ruby](https://img.shields.io/badge/Ruby-3.2-red.svg?logo=ruby&style=flat)
![Rails](https://img.shields.io/badge/Rails-7.1-cc0000.svg?logo=rubyonrails&style=flat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg?logo=postgresql&style=flat)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

**URL:** [https://nekostay.onrender.com](https://nekostay.onrender.com)

## 📖 概要 (Overview)
**「離れていても、心はそばに。」**

Nekostayは、猫の飼い主とシッターを繋ぐ、安心・安全な見守り予約プラットフォームです。
旅行や出張で家を空ける際、ペットホテルではなく「いつものお家」でお世話をしてもらうためのマッチングと、契約・決済・報告までをワンストップで提供します。

### 解決する課題
* **飼い主:** ペットホテルなどの環境変化による猫のストレスを軽減したい。口約束ではなく、しっかりした契約を結びたい。
* **シッター:** お世話の記録や報告をスムーズに行いたい。金銭トラブルを防ぎたい。

## 📸 画面イメージ (Screen Shots)

![Top Page](https://i.gyazo.com/56a8c0e7de46b59922e4d1b393f098d2/raw)

### 📱 リアルタイムなコミュニケーション
Hotwire (Turbo/Stimulus) を活用し、シッターと飼い主がリアルタイムに会話できるチャット機能を実装。

![Chat Demo](https://gyazo.com/83124150b3def37113ee0106fff1b245/raw)

### 📊 お世話管理ダッシュボード
予約状況、契約書、お世話レポートを一元管理。Stripe決済も統合されています。

![Dashboard](https://gyazo.com/73d794a46e1db1cbc8544d814d52cd7e/raw)


## ⚡ 主な機能 (Features)

* **ユーザー機能**
    * ユーザー登録・ログイン (Devise)
    * プロフィール編集 (ActiveStorageによる画像アップロード)
    * ペット情報の登録
* **予約・契約**
    * カレンダーによる日程選択
    * **デジタル契約書の自動生成・表示**
    * お世話内容（食事、トイレ、投薬など）の引継ぎリスト作成
* **コミュニケーション & 報告**
    * **リアルタイムチャット** (Hotwire)
    * 写真付きのお世話日報機能
* **決済**
    * **クレジットカード決済** (Stripe API)

## 🛠 使用技術 (Tech Stack)

| Category | Technology |
| --- | --- |
| **Backend** | Ruby 3.2, Ruby on Rails 7.1 |
| **Frontend** | Hotwire (Turbo, Stimulus), ERB, CSS |
| **Database** | PostgreSQL |
| **Infrastructure** | Docker, Render (PaaS) |
| **Payment** | Stripe API |
| **Version Control** | Git, GitHub |

## 💾 データベース設計 (Database Design)

### Users テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| name | string | null: false |
| email | string | null: false, unique: true |
| encrypted_password | string | null: false |
| introduction | text | |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* has_many :pets
* has_many :stays (as owner)
* has_many :sitter_stays (as sitter)
* has_many :messages
* has_many :checkins

### Pets テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| name | string | null: false |
| species | string | |
| age | integer | |
| gender | integer | |
| user_id | integer | FK, null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* belongs_to :user
* has_many :stays

### Stays テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| start_on | date | null: false |
| end_on | date | null: false |
| place | integer | default: 0 (owner_home) |
| status | integer | default: 0 (draft) |
| notes | text | |
| pet_id | integer | FK, null: false |
| owner_id | integer | FK, null: false |
| sitter_id | integer | FK, null: false |
| paid_at | datetime | |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* belongs_to :pet
* belongs_to :owner (User)
* belongs_to :sitter (User)
* has_many :checkins
* has_many :messages
* has_one :review
* has_one :contract

### Checkins テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| checked_at | datetime | null: false |
| report | text | |
| stay_id | integer | FK, null: false |
| user_id | integer | FK |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* belongs_to :stay
* belongs_to :user

### Messages テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| body | text | null: false |
| stay_id | integer | FK, null: false |
| user_id | integer | FK, null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* belongs_to :stay
* belongs_to :user

### Reviews テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| score | integer | null: false |
| comment | text | |
| stay_id | integer | FK, null: false |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

#### アソシエーション
* belongs_to :stay

### Addresses テーブル
| Column | Type | Options |
| ------ | ---- | ------- |
| id | integer | PK |
| postal_code | string | null: false |
| prefecture | string | null: false |
| city | string | null: false |
| line1 | string | null: false |
| line2 | string | |
| created_at | datetime | null: false |
| updated_at | datetime | null: false |

## 🚀 環境構築 (Installation)

Docker環境で簡単に起動できます。

```bash
# リポジトリのクローン
git clone [https://github.com/leongswan/nekostay.git](https://github.com/leongswan/nekostay.git)
cd nekostay

# コンテナのビルドと起動
docker-compose build
docker-compose up -d

# データベースの作成とマイグレーション
docker-compose exec web rails db:create db:migrate

# サーバー起動確認
# http://localhost:3000 にアクセス
