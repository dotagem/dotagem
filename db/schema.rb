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

ActiveRecord::Schema[7.0].define(version: 2022_08_19_075236) do
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

  create_table "items", force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "name", null: false
    t.string "img"
    t.string "dname"
    t.string "qual"
    t.integer "cost"
    t.string "components"
    t.string "lore"
    t.boolean "created"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_items_on_item_id", unique: true
    t.index ["name"], name: "index_items_on_name", unique: true
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

  create_table "regions", force: :cascade do |t|
    t.integer "region_id", null: false
    t.string "name", null: false
    t.string "localized_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["region_id"], name: "index_regions_on_region_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.integer "telegram_id", null: false
    t.string "telegram_username"
    t.string "telegram_avatar"
    t.integer "steam_id64"
    t.string "steam_id3"
    t.string "steam_nickname"
    t.string "steam_url"
    t.string "steam_avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "telegram_name"
    t.index ["steam_id3"], name: "index_users_on_steam_id3", unique: true
    t.index ["steam_id64"], name: "index_users_on_steam_id64", unique: true
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
  end

end
