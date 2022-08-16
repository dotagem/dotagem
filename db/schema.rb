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

ActiveRecord::Schema[7.0].define(version: 2022_08_16_130325) do
  create_table "game_modes", force: :cascade do |t|
    t.integer "mode_id", null: false
    t.string "name", null: false
    t.string "localized_name"
    t.boolean "balanced", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mode_id"], name: "index_game_modes_on_mode_id", unique: true
  end

  create_table "heroes", force: :cascade do |t|
    t.integer "hero_id", null: false
    t.string "name", null: false
    t.string "localized_name", null: false
    t.string "primary_attr"
    t.string "attack_type"
    t.string "roles"
    t.integer "legs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hero_id"], name: "index_heroes_on_hero_id", unique: true
    t.index ["localized_name"], name: "index_heroes_on_localized_name"
  end

  create_table "lobby_types", force: :cascade do |t|
    t.integer "lobby_id", null: false
    t.string "name", null: false
    t.string "localized_name"
    t.boolean "balanced", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lobby_id"], name: "index_lobby_types_on_lobby_id", unique: true
  end

end
