# データベース設計

## users テーブル
| Column     | Type   | Options                              |
| ---------- | ------ | ------------------------------------ |
| id         | PK     |                                      |
| name       | string | null: false                          |
| email      | string | null: false, unique                  |
| role       | string | enum(owner/sitter/admin), null:false |
| phone      | string |                                      |
| address_id | FK     | references addresses                 |
| verified   | bool   | default: false                       |

## addresses テーブル
| Column      | Type   | Options     |
| ----------- | ------ | ----------- |
| id          | PK     |             |
| postal_code | string | null: false |
| prefecture  | string | null: false |
| city        | string | null: false |
| line1       | string | null: false |
| line2       | string |             |

## pets テーブル
| Column        | Type    | Options                 |
| ------------- | ------- | ----------------------- |
| id            | PK      |                         |
| user_id       | FK      | references users        |
| name          | string  | null: false             |
| breed         | string  |                         |
| sex           | string  |                         |
| birthdate     | date    |                         |
| weight        | decimal |                         |
| spay_neuter   | boolean |                         |
| vaccine_info  | text    |                         |
| medical_notes | text    |                         |

## sitter_profiles テーブル
| Column            | Type    | Options                  |
| ----------------- | ------- | ------------------------ |
| id                | PK      |                          |
| user_id           | FK      | references users         |
| intro             | text    |                          |
| home_type         | string  |                          |
| has_pets          | boolean |                          |
| capacity          | integer |                          |
| insurance_provider| string  |                          |
| license_number    | string  |                          |

## availabilities テーブル
| Column            | Type    | Options                          |
| ----------------- | ------- | -------------------------------- |
| id                | PK      |                                  |
| sitter_profile_id | FK      | references sitter_profiles       |
| date              | date    |                                  |
| status            | string  | enum(open/closed/booked)         |

## stays テーブル
| Column       | Type   | Options                                      |
| ------------ | ------ | -------------------------------------------- |
| id           | PK     |                                              |
| pet_id       | FK     | references pets                              |
| owner_id     | FK     | references users                             |
| sitter_id    | FK     | references users                             |
| place        | string | enum(owner_home/sitter_home)                 |
| start_on     | date   |                                              |
| end_on       | date   |                                              |
| status       | string | enum(draft/active/completed/cancelled)       |
| parent_stay_id| FK    | self reference (14日分割の親子管理)          |

## handoffs テーブル
| Column       | Type     | Options                        |
| ------------ | -------- | ------------------------------ |
| id           | PK       |                                |
| from_stay_id | FK       | references stays               |
| to_stay_id   | FK       | references stays               |
| checklist    | text     |                                |
| scheduled_at | datetime |                                |
| completed_at | datetime |                                |

## checkins テーブル
| Column   | Type     | Options          |
| -------- | -------- | ---------------- |
| id       | PK       |                  |
| stay_id  | FK       | references stays |
| at       | datetime |                  |
| meal     | jsonb    |                  |
| litter   | jsonb    |                  |
| meds     | jsonb    |                  |
| weight   | decimal  |                  |
| memo     | text     |                  |

## messages テーブル
| Column    | Type     | Options          |
| --------- | -------- | ---------------- |
| id        | PK       |                  |
| stay_id   | FK       | references stays |
| sender_id | FK       | references users |
| body      | text     |                  |
| read_at   | datetime |                  |

## contracts テーブル
| Column    | Type     | Options          |
| --------- | -------- | ---------------- |
| id        | PK       |                  |
| stay_id   | FK       | references stays |
| pdf_file  | string   |                  |
| agreed_at | datetime |                  |

## payments テーブル
| Column     | Type    | Options          |
| ---------- | ------- | ---------------- |
| id         | PK      |                  |
| stay_id    | FK      | references stays |
| amount_cents| integer|                  |
| currency   | string  |                  |
| status     | string  | enum(auth/captured/refunded) |
| provider   | string  |                  |
| charge_id  | string  |                  |

## reviews テーブル
| Column   | Type    | Options          |
| -------- | ------- | ---------------- |
| id       | PK      |                  |
| stay_id  | FK      | references stays |
| rater_id | FK      | references users |
| ratee_id | FK      | references users |
| score    | integer |                  |
| comment  | text    |                  |

## emergency_contacts テーブル
| Column  | Type   | Options       |
| ------- | ------ | ------------- |
| id      | PK     |               |
| pet_id  | FK     | references pets|
| name    | string |               |
| phone   | string |               |
| relation| string |               |

## vets テーブル
| Column     | Type   | Options          |
| ---------- | ------ | ---------------- |
| id         | PK     |                  |
| pet_id     | FK     | references pets  |
| clinic_name| string |                  |
| phone      | string |                  |
| address_id | FK     | references addresses |

## media (polymorphic) テーブル
| Column          | Type   | Options                                   |
| --------------- | ------ | ----------------------------------------- |
| id              | PK     |                                           |
| attachable_type | string | polymorphic (checkins, contracts, pets等) |
| attachable_id   | bigint |                                           |
| file            | string |                                           |