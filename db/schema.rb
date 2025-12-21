# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_12_21_165459) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "postal_code", null: false
    t.string "prefecture", null: false
    t.string "city", null: false
    t.string "line1", null: false
    t.string "line2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stay_id", null: false
    t.datetime "checked_at"
    t.decimal "weight", precision: 6, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "meal"
    t.json "litter"
    t.json "meds"
    t.text "memo"
    t.bigint "user_id"
    t.text "report"
    t.integer "food"
    t.integer "pee_count"
    t.integer "poop_count"
    t.integer "mood"
    t.index ["checked_at"], name: "index_checkins_on_checked_at"
    t.index ["stay_id"], name: "index_checkins_on_stay_id"
    t.index ["user_id"], name: "index_checkins_on_user_id"
  end

  create_table "contracts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stay_id", null: false
    t.string "pdf_file"
    t.datetime "agreed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stay_id"], name: "index_contracts_on_stay_id"
  end

  create_table "emergency_contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.string "name"
    t.string "phone"
    t.string "relation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_emergency_contacts_on_pet_id"
  end

  create_table "handoffs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "from_stay_id", null: false
    t.bigint "to_stay_id", null: false
    t.text "checklist"
    t.datetime "scheduled_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_stay_id"], name: "index_handoffs_on_from_stay_id"
    t.index ["to_stay_id"], name: "index_handoffs_on_to_stay_id"
  end

  create_table "media", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "attachable_type", null: false
    t.bigint "attachable_id", null: false
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_media_on_attachable"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body"
    t.bigint "stay_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stay_id"], name: "index_messages_on_stay_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stay_id", null: false
    t.integer "amount_cents"
    t.string "currency"
    t.string "status"
    t.string "provider"
    t.string "charge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charge_id"], name: "index_payments_on_charge_id"
    t.index ["stay_id"], name: "index_payments_on_stay_id"
  end

  create_table "pets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "breed"
    t.string "sex"
    t.date "birthdate"
    t.decimal "weight", precision: 10
    t.boolean "spay_neuter"
    t.text "vaccine_info"
    t.text "medical_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "reviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "stay_id", null: false
    t.bigint "rater_id", null: false
    t.bigint "ratee_id", null: false
    t.integer "score"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ratee_id"], name: "index_reviews_on_ratee_id"
    t.index ["rater_id"], name: "index_reviews_on_rater_id"
    t.index ["stay_id"], name: "index_reviews_on_stay_id"
  end

  create_table "stays", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "pet_id"
    t.bigint "owner_id"
    t.bigint "sitter_id"
    t.string "place"
    t.string "status", default: "draft", null: false
    t.date "start_on", null: false
    t.date "end_on", null: false
    t.bigint "parent_stay_id"
    t.datetime "paid_at"
    t.bigint "user_id", null: false
    t.index ["owner_id"], name: "index_stays_on_owner_id"
    t.index ["parent_stay_id"], name: "index_stays_on_parent_stay_id"
    t.index ["pet_id"], name: "index_stays_on_pet_id"
    t.index ["sitter_id"], name: "index_stays_on_sitter_id"
    t.index ["user_id"], name: "index_stays_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.string "clinic_name"
    t.string "phone"
    t.bigint "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_vets_on_address_id"
    t.index ["pet_id"], name: "index_vets_on_pet_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "checkins", "stays"
  add_foreign_key "checkins", "users"
  add_foreign_key "contracts", "stays"
  add_foreign_key "emergency_contacts", "pets"
  add_foreign_key "handoffs", "stays", column: "from_stay_id"
  add_foreign_key "handoffs", "stays", column: "to_stay_id"
  add_foreign_key "messages", "stays"
  add_foreign_key "messages", "users"
  add_foreign_key "payments", "stays"
  add_foreign_key "pets", "users"
  add_foreign_key "reviews", "stays"
  add_foreign_key "reviews", "users", column: "ratee_id"
  add_foreign_key "reviews", "users", column: "rater_id"
  add_foreign_key "stays", "pets", name: "fk_stays_pet_id"
  add_foreign_key "stays", "stays", column: "parent_stay_id"
  add_foreign_key "stays", "users"
  add_foreign_key "stays", "users", column: "owner_id", name: "fk_stays_owner_id"
  add_foreign_key "stays", "users", column: "sitter_id", name: "fk_stays_sitter_id"
  add_foreign_key "vets", "addresses"
  add_foreign_key "vets", "pets"
end
