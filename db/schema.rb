# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140909103037) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addons", force: true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addons", ["product_id"], name: "index_addons_on_product_id", using: :btree

  create_table "app_types", force: true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_types", ["product_id"], name: "index_app_types_on_product_id", using: :btree

  create_table "dockerservers", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gear_profiles", force: true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gear_profiles", ["product_id"], name: "index_gear_profiles_on_product_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "tag"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rundockerservers", force: true do |t|
    t.integer  "run_id"
    t.integer  "dockerserver_id"
    t.integer  "image_id"
    t.integer  "jobcount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rundockerservers", ["dockerserver_id"], name: "index_rundockerservers_on_dockerserver_id", using: :btree
  add_index "rundockerservers", ["image_id"], name: "index_rundockerservers_on_image_id", using: :btree
  add_index "rundockerservers", ["run_id"], name: "index_rundockerservers_on_run_id", using: :btree

  create_table "runresults", force: true do |t|
    t.integer  "run_id"
    t.integer  "no_of_observations"
    t.string   "app_creation_mean"
    t.string   "app_creation_stdev"
    t.string   "app_creation_values"
    t.string   "request_duration_before_scaling"
    t.string   "request_duration_before_scaling_stdev"
    t.string   "slow_requests_before_scaling"
    t.string   "request_duration_after_1_scaling" 
    t.string   "request_duration_after_2_scaling"
    t.string   "request_duration_after_3_scaling"
    t.string   "request_duration_after_4_scaling"
    t.string   "request_duration_after_5_scaling"
    t.string   "request_duration_after_6_scaling"
    t.string   "request_duration_after_7_scaling"
    t.string   "request_duration_after_8_scaling"
    t.string   "request_duration_after_9_scaling"
    t.string   "request_duration_after_10_scaling"
    t.string   "request_duration_after_1_scaling_stdev" 
    t.string   "request_duration_after_2_scaling_stdev"
    t.string   "request_duration_after_3_scaling_stdev"
    t.string   "request_duration_after_4_scaling_stdev"
    t.string   "request_duration_after_5_scaling_stdev"
    t.string   "request_duration_after_6_scaling_stdev"
    t.string   "request_duration_after_7_scaling_stdev"
    t.string   "request_duration_after_8_scaling_stdev"
    t.string   "request_duration_after_9_scaling_stdev"
    t.string   "request_duration_after_10_scaling_stdev"
    t.string   "slow_requests_after_1_scaling" 
    t.string   "slow_requests_after_2_scaling"
    t.string   "slow_requests_after_3_scaling"
    t.string   "slow_requests_after_4_scaling"
    t.string   "slow_requests_after_5_scaling"
    t.string   "slow_requests_after_6_scaling"
    t.string   "slow_requests_after_7_scaling"
    t.string   "slow_requests_after_8_scaling"
    t.string   "slow_requests_after_9_scaling"
    t.string   "slow_requests_after_10_scaling"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "runresults", ["run_id"], name: "index_runresults_on_run_id", using: :btree

  create_table "runs", force: true do |t|
    t.integer  "product_id"
    t.string   "login"
    t.string   "password"
    t.string   "heroku_netrc"
    t.string   "broker"
    t.integer  "scale"
    t.string   "from_code"
    t.string   "envvars"
    t.integer  "requestcount"
    t.integer  "concurrency"
    t.integer  "gear_profile_id"
    t.integer  "app_type_id"
    t.integer  "addon_id"
    t.integer  "rundockerserver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id"
    t.integer  "duration_threshold"
  end

  add_index "runs", ["addon_id"], name: "index_runs_on_addon_id", using: :btree
  add_index "runs", ["app_type_id"], name: "index_runs_on_app_type_id", using: :btree
  add_index "runs", ["gear_profile_id"], name: "index_runs_on_gear_profile_id", using: :btree
  add_index "runs", ["product_id"], name: "index_runs_on_product_id", using: :btree
  add_index "runs", ["rundockerserver_id"], name: "index_runs_on_rundockerserver_id", using: :btree
  add_index "runs", ["status_id"], name: "index_runs_on_status_id", using: :btree

  create_table "statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
end
