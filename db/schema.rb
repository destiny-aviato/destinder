# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170730161449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "microposts", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "game_type"
    t.text     "user_stats"
    t.string   "platform"
    t.string   "raid_difficulty"
    t.index ["user_id", "created_at"], name: "index_microposts_on_user_id_and_created_at", using: :btree
    t.index ["user_id"], name: "index_microposts_on_user_id", using: :btree
  end

  create_table "player_stats", force: :cascade do |t|
    t.string   "display_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "membership_type"
    t.text     "stats_data"
    t.text     "characters"
  end

  create_table "team_stats", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "membership_type"
    t.text     "stats_data"
    t.text     "characters"
    t.text     "display_name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "remember_token"
    t.integer  "sign_in_count",          default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "membership_id"
    t.string   "display_name"
    t.string   "unique_name"
    t.string   "request_data"
    t.string   "profile_picture"
    t.string   "about"
    t.string   "xbox_display_name"
    t.string   "psn_display_name"
    t.string   "api_membership_id"
    t.string   "api_membership_type"
    t.string   "elo"
    t.index ["provider"], name: "index_users_on_provider", using: :btree
    t.index ["uid"], name: "index_users_on_uid", using: :btree
  end

  add_foreign_key "microposts", "users"
end
