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


## addresses テーブル
| Column       | Type   | Options     |
| ------------ | ------ | ----------- |
| id           | PK     |             |
| postal_code  | string | null: false |
| prefecture   | string | null: false |
| city         | string | null: false |
| line1        | string | null: false |
| line2        | string |             |


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


## availabilities テーブル
| Column              | Type   | Options                     |
| ------------------- | ------ | --------------------------- |
| id                  | PK     |                             |
| sitter_profile_id   | FK     | references sitter_profiles  |
| date                | date   |                             |
| status              | string | enum(open/closed/booked)    |


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


**Indexes**
- `index_stays_on_pet_id`
- `index_stays_on_owner_id`
- `index_stays_on_sitter_id`
- `index_stays_on_parent_stay_id`

**Relations**
- `belongs_to :owner, class_name: "User"`

- `belongs_to :sitter, class_name: "User", optional: true`

- `belongs_to :pet, optional: true`

- `belongs_to :parent_stay, class_name: "Stay", optional: true`

- `has_many :children, class_name: "Stay", foreign_key: :parent_stay_id`

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

**Relations**
- `belongs_to :from_stay, class_name: "Stay"`
- `belongs_to :to_stay, class_name: "Stay"`

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


## messages テーブル
| Column     | Type     | Options          |
| ---------- | -------- | ---------------- |
| id         | PK       |                  |
| stay_id    | FK       | references stays |
| sender_id  | FK       | references users |
| body       | text     |                  |
| read_at    | datetime |                  |


## contracts テーブル
| Column     | Type     | Options          |
| ---------- | -------- | ---------------- |
| id         | PK       |                  |
| stay_id    | FK       | references stays |
| pdf_file   | string   |                  |
| agreed_at  | datetime |                  |


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


## reviews テーブル
| Column    | Type    | Options          |
| --------- | ------- | ---------------- |
| id        | PK      |                  |
| stay_id   | FK      | references stays |
| rater_id  | FK      | references users |
| ratee_id  | FK      | references users |
| score     | integer |                  |
| comment   | text    |                  |


## emergency_contacts テーブル
| Column   | Type   | Options         |
| -------- | ------ | --------------- |
| id       | PK     |                 |
| pet_id   | FK     | references pets |
| name     | string |                 |
| phone    | string |                 |
| relation | string |                 |


## vets テーブル
| Column       | Type   | Options              |
| ------------ | ------ | -------------------- |
| id           | PK     |                      |
| pet_id       | FK     | references pets      |
| clinic_name  | string |                      |
| phone        | string |                      |
| address_id   | FK     | references addresses |


## media (polymorphic) テーブル
| Column           | Type   | Options                                |
| ---------------- | ------ | -------------------------------------- |
| id               | PK     |                                        |
| attachable_type  | string | polymorphic（checkins/contracts/pets 等） |
| attachable_id    | bigint |                                        |
| file             | string |                                        |


