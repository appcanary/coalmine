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

ActiveRecord::Schema.define(version: 20160603150414) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beta_users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_plans", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "subscription_plan_id"
    t.integer  "available_subscription_plans", default: [],              array: true
    t.datetime "started_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "billing_plans", ["subscription_plan_id"], name: "index_billing_plans_on_subscription_plan_id", using: :btree
  add_index "billing_plans", ["user_id"], name: "index_billing_plans_on_user_id", using: :btree

  create_table "is_it_vuln_results", force: :cascade do |t|
    t.string   "ident",       null: false
    t.text     "result"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "pre_user_id"
  end

  add_index "is_it_vuln_results", ["ident"], name: "index_is_it_vuln_results_on_ident", using: :btree
  add_index "is_it_vuln_results", ["pre_user_id"], name: "index_is_it_vuln_results_on_pre_user_id", using: :btree

  create_table "pre_users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "preferred_platform"
    t.boolean  "from_isitvuln",      default: false
    t.string   "source",             default: "unassigned", null: false
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.integer  "value"
    t.integer  "unit_value"
    t.integer  "limit"
    t.string   "label"
    t.string   "comment"
    t.boolean  "default",    default: false, null: false
    t.boolean  "discount",   default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "subscription_plans", ["default"], name: "index_subscription_plans_on_default", using: :btree
  add_index "subscription_plans", ["discount"], name: "index_subscription_plans_on_discount", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                                     null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "activation_state"
    t.string   "activation_token"
    t.datetime "activation_token_expires_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address"
    t.integer  "failed_logins_count",                       default: 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.string   "token"
    t.boolean  "onboarded",                                 default: false
    t.boolean  "is_admin",                                  default: false, null: false
    t.string   "beta_signup_source"
    t.string   "stripe_customer_id"
    t.string   "name"
    t.string   "subscription_plan"
    t.boolean  "newsletter_email_consent",                  default: true,  null: false
    t.boolean  "api_beta",                                  default: false, null: false
    t.boolean  "marketing_email_consent",                   default: true,  null: false
    t.boolean  "daily_email_consent",                       default: false, null: false
    t.integer  "datomic_id",                      limit: 8
    t.boolean  "invoiced_manually",                         default: false
  end

  add_index "users", ["activation_token"], name: "index_users_on_activation_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", using: :btree

  add_foreign_key "is_it_vuln_results", "pre_users"
end
