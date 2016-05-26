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

ActiveRecord::Schema.define(version: 20160522191756) do

  create_table "package_sets", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "path"
    t.string   "platform"
    t.string   "release"
    t.integer  "last_crc",   limit: 8
    t.boolean  "from_api"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "package_sets", ["account_id"], name: "index_package_sets_on_account_id"

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "source_name"
    t.string   "platform"
    t.string   "release"
    t.string   "version"
    t.string   "artifact"
    t.string   "epoch"
    t.string   "arch"
    t.string   "filename"
    t.string   "checksum"
    t.string   "origin"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "packages_package_sets", force: :cascade do |t|
    t.integer  "package_set_id"
    t.integer  "package_id"
    t.boolean  "vulnerable",     default: false, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "packages_package_sets", ["package_id"], name: "index_packages_package_sets_on_package_id"
  add_index "packages_package_sets", ["package_set_id"], name: "index_packages_package_sets_on_package_set_id"

  create_table "vulnerabilities", force: :cascade do |t|
    t.string   "package_name"
    t.string   "package_platform"
    t.string   "title"
    t.datetime "reported_at"
    t.text     "description"
    t.string   "criticality"
    t.text     "patched_versions"
    t.text     "unaffected_versions"
    t.string   "cve_id"
    t.string   "usn_id"
    t.string   "dsa_id"
    t.string   "rhsa_id"
    t.string   "cesa_id"
    t.string   "source"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "vulnerable_packages", force: :cascade do |t|
    t.integer  "package_id"
    t.integer  "vulnerability_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "vulnerable_packages", ["package_id"], name: "index_vulnerable_packages_on_package_id"
  add_index "vulnerable_packages", ["vulnerability_id"], name: "index_vulnerable_packages_on_vulnerability_id"

end
