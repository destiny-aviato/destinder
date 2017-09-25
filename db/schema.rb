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

ActiveRecord::Schema.define(version: 20_170_911_145_727) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'badges_sashes', force: :cascade do |t|
    t.integer  'badge_id'
    t.integer  'sash_id'
    t.boolean  'notified_user', default: false
    t.datetime 'created_at'
    t.index %w[badge_id sash_id], name: 'index_badges_sashes_on_badge_id_and_sash_id', using: :btree
    t.index ['badge_id'], name: 'index_badges_sashes_on_badge_id', using: :btree
    t.index ['sash_id'], name: 'index_badges_sashes_on_sash_id', using: :btree
  end

  create_table 'merit_actions', force: :cascade do |t|
    t.integer  'user_id'
    t.string   'action_method'
    t.integer  'action_value'
    t.boolean  'had_errors', default: false
    t.string   'target_model'
    t.integer  'target_id'
    t.text     'target_data'
    t.boolean  'processed', default: false
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
  end

  create_table 'merit_activity_logs', force: :cascade do |t|
    t.integer  'action_id'
    t.string   'related_change_type'
    t.integer  'related_change_id'
    t.string   'description'
    t.datetime 'created_at'
  end

  create_table 'merit_score_points', force: :cascade do |t|
    t.integer  'score_id'
    t.integer  'num_points', default: 0
    t.string   'log'
    t.datetime 'created_at'
  end

  create_table 'merit_scores', force: :cascade do |t|
    t.integer 'sash_id'
    t.string  'category', default: 'default'
  end

  create_table 'microposts', force: :cascade do |t|
    t.text     'content'
    t.integer  'user_id'
    t.datetime 'created_at',                    null: false
    t.datetime 'updated_at',                    null: false
    t.string   'game_type'
    t.text     'user_stats'
    t.string   'platform'
    t.string   'raid_difficulty'
    t.string   'checkpoint'
    t.string   'character_choice'
    t.boolean  'mic_required'
    t.string   'looking_for'
    t.string   'elo_min'
    t.string   'elo_max'
    t.string   'kd_min'
    t.string   'kd_max'
    t.integer  'elo'
    t.float    'kd'
    t.string   'destiny_version'
    t.text     'fireteam', default: [], array: true
    t.text     'fireteam_stats'
    t.index %w[user_id created_at], name: 'index_microposts_on_user_id_and_created_at', using: :btree
    t.index ['user_id'], name: 'index_microposts_on_user_id', using: :btree
  end

  create_table 'player_stats', force: :cascade do |t|
    t.string   'display_name'
    t.datetime 'created_at',      null: false
    t.datetime 'updated_at',      null: false
    t.string   'membership_type'
    t.text     'stats_data'
    t.text     'characters'
  end

  create_table 'sashes', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'team_stats', force: :cascade do |t|
    t.string   'membership_type'
    t.text     'stats_data'
    t.text     'characters'
    t.text     'display_name'
    t.datetime 'created_at',      null: false
    t.datetime 'updated_at',      null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string   'email'
    t.string   'encrypted_password'
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.string   'remember_token'
    t.integer  'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet     'current_sign_in_ip'
    t.inet     'last_sign_in_ip'
    t.datetime 'created_at',                         null: false
    t.datetime 'updated_at',                         null: false
    t.string   'provider'
    t.string   'uid'
    t.string   'membership_id'
    t.string   'display_name'
    t.string   'unique_name'
    t.string   'request_data'
    t.string   'profile_picture'
    t.string   'about'
    t.string   'xbox_display_name'
    t.string   'psn_display_name'
    t.string   'api_membership_id'
    t.string   'api_membership_type'
    t.string   'elo'
    t.integer  'sash_id'
    t.integer  'level', default: 0
    t.datetime 'last_active_at'
    t.index ['provider'], name: 'index_users_on_provider', using: :btree
    t.index ['uid'], name: 'index_users_on_uid', using: :btree
  end

  create_table 'votes', force: :cascade do |t|
    t.boolean  'vote', default: false, null: false
    t.string   'voteable_type',                 null: false
    t.integer  'voteable_id',                   null: false
    t.string   'voter_type'
    t.integer  'voter_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.index %w[voteable_id voteable_type], name: 'index_votes_on_voteable_id_and_voteable_type', using: :btree
    t.index %w[voter_id voter_type voteable_id voteable_type], name: 'fk_one_vote_per_user_per_entity', unique: true, using: :btree
    t.index %w[voter_id voter_type], name: 'index_votes_on_voter_id_and_voter_type', using: :btree
  end

  add_foreign_key 'microposts', 'users'
end
