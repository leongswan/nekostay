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