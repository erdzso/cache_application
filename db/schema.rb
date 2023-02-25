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

ActiveRecord::Schema[7.0].define(version: 2023_02_25_113239) do
  create_table "api_callings", charset: "utf8mb4", force: :cascade do |t|
    t.string "api_caller_type", null: false
    t.bigint "api_caller_id", null: false
    t.datetime "expired_at"
    t.integer "hit_count", null: false
    t.integer "state", null: false
    t.text "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_caller_type", "api_caller_id"], name: "index_api_callings_on_api_caller"
  end

  create_table "searches", charset: "utf8mb4", force: :cascade do |t|
    t.string "type", null: false
    t.string "query", null: false
    t.integer "page", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "query", "page"], name: "index_searches_on_type_and_query_and_page", unique: true
  end

end
