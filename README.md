# 猫の在宅長期ケアアプリ（仮称：NekoStay）MVP 開発手順ブループリント
 目的：ペットホテルの「長期預かりの制限」を前提に、飼い主の自宅やシッターの自宅で安全にロングステイ（1か月以上）を実現するためのプロダクト。14日上限に配慮し、ステイ分割・引継ぎ（ハンドオフ）・遠隔見守り・記録・契約・決済を一気通貫で提供。

0. 法規・運用の前提（プロダクト要件に直結）
動物取扱業の該当可能性：有償預かり・反復継続は該当し得る → 事業者向けには事業者モード（登録番号・所在地・責任者）を保持。

14日上限への対策（MVPで実装）

ステイを14日以内で自動分割（例：28日→14日×2回）

ハンドオフ機能：同一または別シッター／同一場所で新規契約として継続

証跡：同意書・契約書PDF、チェックイン／アウト時刻、写真／動画ログを保存

面会・健康確認：獣医診察・面会のスケジュールを分割間に挿入（任意）

保険・事故対応：第三者賠償・医療費補償の保険情報を必須項目に（後述DB）

⚠️ 本番運用前に、自治体の担当窓口・専門家へ最新ルールの確認と約款レビューを行うこと。

1. ユースケース & ペルソナ
飼い主：長期出張・帰省・入院等で最短1か月の不在。自宅ケア優先。合鍵管理とカメラで見守りたい。

シッター：個人~小規模事業者。自宅預かり/訪問可。スケジュール最適化と事故時のガイドが必要。

管理者：トラブル時介入、本人確認、返金・キャンセルポリシーの執行。

2. MVPスコープ（最小で価値を出す機能）
アカウント（飼い主/シッター/管理者）

猫プロフィール（ワクチン・既往歴・投薬・食事・トイレ）

ステイ作成（開始/終了、場所：自宅orシッター宅、14日自動分割）

ハンドオフ（分割間の引継ぎ、鍵・餌・薬・トイレ砂の確認チェックリスト）

日次チェックイン（写真/体重/食事/排泄/服薬ログ、緊急ボタン）

メッセージ（飼い主↔シッター、画像添付）

決済（予約時前受金、分割ごとに支払い確定／エスクロー）

契約書PDF生成（テンプレ+差し込み、電子同意）

通知（Web/PWAプッシュ・メール）

3. 画面フロー（MVP）
トップ（目的説明→CTAs）

新規登録/本人確認（身分証アップロードは後続スプリント）

猫登録（基本/健康/食事/トイレ/性格）

予約作成（期間・場所・シッター選択 or 指名なし公募）

見積→契約→決済→日次レポート閲覧

分割満了前：自動ハンドオフ確認ダイアログ

ステイ終了：レビュー&支払い確定

4. アーキテクチャ / 技術選定
Backend：Ruby on Rails 7.1（API + Server-rendered Hybrid／Turbo & Stimulus）

Auth：Devise（ロール：owner/sitter/admin）。本人確認は後続。

DB：PostgreSQL（Heroku/Render）。

Storage：Active Storage（S3 互換）。

決済：Stripe（PaymentIntent + Connect Standardでシッターへ分配 将来）。

通知：ActionMailer + Web Push（VAPID）

フロント：Rails View + Turbo（Owner/Sitterダッシュボード）

インフラ：Render（既存運用に合わせる）

監視：Sentry / Logtail など（後続）

5. データベース設計 (データモデル)
# データベース設計

## users テーブル
| Column      | Type   | Options                               |
| ----------- | ------ | ------------------------------------- |
| id          | PK     |                                       |
| name        | string | null: false                           |
| email       | string | null: false, unique                   |
| role        | string | enum(owner/sitter/admin), null:false  |
| phone       | string |                                       |
| address_id  | FK     | references addresses                  |
| verified    | bool   | default: false                        |

### アソシエーション
belongs_to :address, optional: true
has_many :pets
has_one :sitter_profile # ユーザーは1つのシッタープロフィールを持つ
has_many :owned_stays, class_name: "Stay", foreign_key: "owner_id"
has_many :sitted_stays, class_name: "Stay", foreign_key: "sitter_id"
has_many :sent_messages, class_name: "Message", foreign_key: "sender_id"
has_many :given_reviews, class_name: "Review", foreign_key: "rater_id"
has_many :received_reviews, class_name: "Review", foreign_key: "ratee_id"


## addresses テーブル
| Column       | Type   | Options     |
| ------------ | ------ | ----------- |
| id           | PK     |             |
| postal_code  | string | null: false |
| prefecture   | string | null: false |
| city         | string | null: false |
| line1        | string | null: false |
| line2        | string |             |

### アソシエーション
has_many :users
has_many :vets


## pets テーブル
| Column         | Type    | Options          |
| -------------- | ------- | ---------------- |
| id             | PK      |                  |
| user_id        | FK      | references users |
| name           | string  | null: false      |
| breed          | string  |                  |
| sex            | string  |                  |
| birthdate      | date    |                  |
| weight         | decimal |                  |
| spay_neuter    | boolean |                  |
| vaccine_info   | text    |                  |
| medical_notes  | text    |                  |

### アソシエーション
belongs_to :user # or :owner, class_name: "User"
has_many :stays
has_many :emergency_contacts
has_many :vets
has_many :media, as: :attachable # ポリモーフィック


## sitter_profiles テーブル
| Column              | Type    | Options          |
| ------------------- | ------- | ---------------- |
| id                  | PK      |                  |
| user_id             | FK      | references users |
| intro               | text    |                  |
| home_type           | string  |                  |
| has_pets            | boolean |                  |
| capacity            | integer |                  |
| insurance_provider  | string  |                  |
| license_number      | string  |                  |

### アソシエーション
belongs_to :user
has_many :availabilities


## availabilities テーブル
| Column              | Type   | Options                     |
| ------------------- | ------ | --------------------------- |
| id                  | PK     |                             |
| sitter_profile_id   | FK     | references sitter_profiles  |
| date                | date   |                             |
| status              | string | enum(open/closed/booked)    |

### アソシエーション
belongs_to :sitter_profile


## stays テーブル
| Column           | Type   | Options                                                |
| ---------------- | ------ | ------------------------------------------------------ |
| id               | PK     |                                                        |
| pet_id           | FK     | references pets                                        |
| owner_id         | FK     | references users                                       |
| sitter_id        | FK     | references users                                       |
| place            | string | enum(owner_home/sitter_home)                           |
| start_on         | date   | not null                                               |
| end_on           | date   | not null                                               |
| status           | string | enum(draft/active/completed/cancelled), default: draft |
| parent_stay_id   | FK     | self reference → references stays(id)                  |
| notes            | text   |                                                        |

### アソシエーション
belongs_to :owner, class_name: "User", foreign_key: "owner_id"
belongs_to :sitter, class_name: "User", foreign_key: "sitter_id", optional: true
belongs_to :pet
belongs_to :parent_stay, class_name: "Stay", optional: true

has_many :children, class_name: "Stay", foreign_key: :parent_stay_id
has_many :checkins
has_many :messages
has_many :contracts
has_many :payments
has_many :reviews

**handoffs テーブルとの関連**
has_one :outgoing_handoff, class_name: "Handoff", foreign_key: "from_stay_id"
has_one :incoming_handoff, class_name: "Handoff", foreign_key: "to_stay_id"

### 分割運用メモ
- 1件の長期 Stay を 14日単位に分割する際、**元の Stay を親**、新規作成する 14日区切りの Stay を**子**として保存。
- 二重分割防止のため、親に `children.exists?` がある場合は再分割をブロック（`StaySplitter` 内で実装）。
- 親を残す／削除するはオプション（`save_splits!(destroy_original: true/false)`）。

## handoffs テーブル
| Column         | Type     | Options          |
| -------------- | -------- | ---------------- |
| id             | PK       |                  |
| from_stay_id   | FK       | references stays |
| to_stay_id     | FK       | references stays |
| checklist      | text     |                  |
| scheduled_at   | datetime |                  |
| completed_at   | datetime |                  |

### アソシエーション
belongs_to :from_stay, class_name: "Stay", foreign_key: "from_stay_id"
belongs_to :to_stay, class_name: "Stay", foreign_key: "to_stay_id"

## tasks テーブル
(ブループリントに含まれていましたが、checkins テーブルで代替される可能性があります) 
| Column  | Type     | Options                             |
| ------- | -------- | ----------------------------------- |
| id      | PK       |                                     |
| stay_id | FK       | references stays                    |
| kind    | string   | enum(feed/litter/meds/weight/photo) |
| due_at  | datetime |                                     |
| done_at | datetime |                                     |
| notes   | text     |                                     |

### アソシエーション
belongs_to :stay

## checkins テーブル
| Column      | Type     | Options          |
| ----------- | -------- | ---------------- |
| id          | PK       |                  |
| stay_id     | FK       | references stays |
| checked_at  | datetime |                  |
| meal        | json     |                  |
| litter      | json     |                  |
| meds        | json     |                  |
| weight      | decimal  | precision: 6, scale: 2 |
| memo        | text     |                  |

### アソシエーション
belongs_to :stay
has_many :media, as: :attachable # ポリモーフィック


## messages テーブル
| Column     | Type     | Options          |
| ---------- | -------- | ---------------- |
| id         | PK       |                  |
| stay_id    | FK       | references stays |
| sender_id  | FK       | references users |
| body       | text     |                  |
| read_at    | datetime |                  |

### アソシエーション
belongs_to :stay
belongs_to :sender, class_name: "User", foreign_key: "sender_id"

## contracts テーブル
| Column     | Type     | Options          |
| ---------- | -------- | ---------------- |
| id         | PK       |                  |
| stay_id    | FK       | references stays |
| pdf_file   | string   |                  |
| agreed_at  | datetime |                  |

### アソシエーション
belongs_to :stay
has_many :media, as: :attachable # ポリモーフィック

## payments テーブル
| Column        | Type    | Options                      |
| ------------- | ------- | ---------------------------- |
| id            | PK      |                              |
| stay_id       | FK      | references stays             |
| amount_cents  | integer |                              |
| currency      | string  | 例: "JPY"                    |
| status        | string  | enum(auth/captured/refunded) |
| provider      | string  | 例: "stripe"                 |
| charge_id     | string  | プロバイダ側のID、一意制約推奨  |

### アソシエーション
belongs_to :stay


## reviews テーブル
| Column    | Type    | Options          |
| --------- | ------- | ---------------- |
| id        | PK      |                  |
| stay_id   | FK      | references stays |
| rater_id  | FK      | references users |
| ratee_id  | FK      | references users |
| score     | integer |                  |
| comment   | text    |                  |

### アソシエーション
belongs_to :stay
belongs_to :rater, class_name: "User", foreign_key: "rater_id"
belongs_to :ratee, class_name: "User", foreign_key: "ratee_id"


## emergency_contacts テーブル
| Column   | Type   | Options         |
| -------- | ------ | --------------- |
| id       | PK     |                 |
| pet_id   | FK     | references pets |
| name     | string |                 |
| phone    | string |                 |
| relation | string |                 |

### アソシエーション
belongs_to :pet


## vets テーブル
| Column       | Type   | Options              |
| ------------ | ------ | -------------------- |
| id           | PK     |                      |
| pet_id       | FK     | references pets      |
| clinic_name  | string |                      |
| phone        | string |                      |
| address_id   | FK     | references addresses |

### アソシエーション
belongs_to :pet
belongs_to :address, optional: true


## media (polymorphic) テーブル
| Column           | Type   | Options                                |
| ---------------- | ------ | -------------------------------------- |
| id               | PK     |                                        |
| attachable_type  | string | polymorphic（checkins/contracts/pets 等） |
| attachable_id    | bigint |                                        |
| file             | string |                                        |

### アソシエーション
belongs_to :attachable, polymorphic: true

6. Rails 実装手順（スプリント計画：3〜4週）
Sprint 0：雛形 & 認証
Rails新規作成・初期設定（pg, devise, importmap, turbo, stimulus）

Devise User（role列追加）

静的ページ（トップ・利用規約・プライバシー）

Bash

rails new nekostay --database=postgresql --skip-javascript
cd nekostay
bundle add devise importmap-rails turbo-rails stimulus-rails pagy dotenv-rails
bin/rails g devise:install
bin/rails g devise User
bin/rails g migration AddRoleToUsers role:string
bin/rails db:create db:migrate
Sprint 1：猫・プロフィール・基本台帳
Active Storage 有効化、猫アイコン画像等の添付

Bash

bin/rails g scaffold Address postal_code prefecture city line1 line2
bin/rails g scaffold Pet user:references name breed sex birthdate:date weight:decimal spay_neuter:boolean vaccine_info:text medical_notes:text
bin/rails g scaffold SitterProfile user:references intro:text home_type has_pets:boolean capacity:integer insurance_provider license_number
bin/rails db:migrate
Sprint 2：ステイ/分割/ハンドオフ
14日自動分割サービス：StaySplitter.split!(stay) を作成

ハンドオフ画面：チェックリスト（鍵/餌/薬/トイレ砂/説明書）

Bash

bin/rails g scaffold Stay pet:references owner:references sitter:references place:string start_on:date end_on:date status:string parent_stay:references
bin/rails g scaffold Handoff from_stay:references to_stay:references checklist:text scheduled_at:datetime completed_at:datetime
bin/rails db:migrate
Sprint 3：日次ログ・メッセージ・契約・決済
契約PDF：Prawn/Docx→PDF + 電子同意（チェック + タイムスタンプ）

Stripe：予約時PaymentIntent作成、ステイ完了でキャプチャ

Bash

bin/rails g scaffold Checkin stay:references at:datetime meal:jsonb litter:jsonb meds:jsonb weight:decimal memo:text
bin/rails g scaffold Message stay:references sender:references body:text read_at:datetime
bin/rails g scaffold Contract stay:references agreed_at:datetime
bin/rails g scaffold Payment stay:references amount_cents:integer currency status provider charge_id
bin/rails db:migrate
Sprint 4：ダッシュボード/通知/ポリシー
飼い主・シッターのダッシュボード（今日のタスク、未提出チェックイン、次回ハンドオフ）

Web Push（VAPID）／メール（ActionMailer）

料金・キャンセル・返金ポリシーを静的ページに明示

7. 14日自動分割の擬似コード
Ruby

class StaySplitter
  MAX_DAYS = 14
  
  def self.split!(stay)
    current_start = stay.start_on
    while current_start < stay.end_on
      segment_end = [current_start + (MAX_DAYS - 1), stay.end_on].min
      child = stay.children.create!(
        start_on: current_start, 
        end_on: segment_end, 
        owner: stay.owner, 
        sitter: stay.sitter, 
        place: stay.place, 
        status: "active"
      )
      current_start = segment_end + 1
    end
  end
end
8. 料金とモネタイズ（MVP）
価格：日額（平日/週末/繁忙期）×日数。分割単位で決済確定。

手数料：10%〜15%（決済手数料込）。

オプション：投薬・追加清掃・送迎・カメラ貸出。

9. リスク・セキュリティ
個人情報/鍵の取り扱い：受け渡し手順・身分証撮影・保管ボックスIDを記録。

緊急時：緊急連絡先＋かかりつけ獣医情報必須。SOPをアプリ内に常時表示。

メディカル：体重・食事・排泄の異常検知ルール（連続N回未入力/閾値超過で警告）。

10. テスト観点（受け入れ条件の例）
28日予約を作ると、14日×2件のStayが自動生成される

分割間にハンドオフ予定が自動提案・作成できる

日次チェックイン未提出で通知が飛ぶ

契約PDFが日付・当事者・猫情報を含み、改ざん防止のハッシュが保存される

ステイ完了レビューで支払い確定、Stripeダッシュボードに反映

11. デプロイ & 運用
Render：PostgreSQL・環境変数（STRIPE_SECRET, MAILER_, VAPID_）

バックアップ：DB自動バックアップ、Active Storageのリージョン冗長

監視：エラーレポート、ジョブ遅延、決済失敗通知

12. 次フェーズ（MVP後）
本人確認/KYC、プロフィール公開、検索・ランキング

Stripe Connectで自動配分、売上レポート

IoT連携（体重計、給餌器、トイレセンサー）

マルチペット対応の一括タスク、カレンダー同期

多言語（JP/EN）

13. プロジェクト運営テンプレ
チケット雛形（What/Why/Done）

PRテンプレ（スクショ、テスト手順）

利用規約/同意書の雛形（TODO: リーガルレビュー）

付録A：Mermaid ER 図（簡易）
コード スニペット

erDiagram
  USERS ||--o{ PETS : has
  USERS ||--o{ SITTER_PROFILES : has
  SITTER_PROFILES ||--o{ AVAILABILITIES : has
  USERS ||--o{ STAYS : owner
  USERS ||--o{ STAYS : sitter
  PETS ||--o{ STAYS : has
  STAYS ||--o{ HANDOFFS : has
  STAYS ||--o{ CHECKINS : has
  STAYS ||--o{ MESSAGES : has
  STAYS ||--o{ PAYMENTS : has
  STAYS ||--o{ CONTRACTS : has
  STAYS ||--o{ REVIEWS : has
  PETS ||--o{ EMERGENCY_CONTACTS : has
  PETS ||--o{ VETS : has
付録B：主要ルーティング（抜粋）
Ruby

# config/routes.rb
resources :pets
resources :stays do
  resources :checkins, only: [:index, :create]
  resources :messages, only: [:index, :create]
  resource  :contract, only: [:show, :create]
  resource  :payment,  only: [:show, :create]
  collection do
    post :quote
  end
end
resources :handoffs, only: [:new, :create, :update]






