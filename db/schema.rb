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

ActiveRecord::Schema.define(version: 20160604200811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bundle_archives", force: :cascade do |t|
    t.integer  "bundle_id",            null: false
    t.integer  "account_id",           null: false
    t.string   "name"
    t.string   "path"
    t.string   "platform",             null: false
    t.string   "release"
    t.integer  "last_crc",   limit: 8
    t.boolean  "from_api"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "valid_at",             null: false
    t.datetime "expired_at",           null: false
  end

  add_index "bundle_archives", ["account_id"], name: "index_bundle_archives_on_account_id", using: :btree
  add_index "bundle_archives", ["bundle_id"], name: "index_bundle_archives_on_bundle_id", using: :btree
  add_index "bundle_archives", ["expired_at"], name: "index_bundle_archives_on_expired_at", using: :btree
  add_index "bundle_archives", ["valid_at"], name: "index_bundle_archives_on_valid_at", using: :btree

  create_table "bundled_package_archives", force: :cascade do |t|
    t.integer  "bundled_package_id", null: false
    t.integer  "bundle_id",          null: false
    t.integer  "package_id",         null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "valid_at",           null: false
    t.datetime "expired_at",         null: false
  end

  add_index "bundled_package_archives", ["bundle_id"], name: "index_bundled_package_archives_on_bundle_id", using: :btree
  add_index "bundled_package_archives", ["bundled_package_id"], name: "index_bundled_package_archives_on_bundled_package_id", using: :btree
  add_index "bundled_package_archives", ["expired_at"], name: "index_bundled_package_archives_on_expired_at", using: :btree
  add_index "bundled_package_archives", ["package_id"], name: "index_bundled_package_archives_on_package_id", using: :btree
  add_index "bundled_package_archives", ["valid_at"], name: "index_bundled_package_archives_on_valid_at", using: :btree

  create_table "bundled_packages", force: :cascade do |t|
    t.integer  "bundle_id",                       null: false
    t.integer  "package_id",                      null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "valid_at",   default: "now()",    null: false
    t.datetime "expired_at", default: 'Infinity', null: false
  end

  add_index "bundled_packages", ["bundle_id"], name: "index_bundled_packages_on_bundle_id", using: :btree
  add_index "bundled_packages", ["expired_at"], name: "index_bundled_packages_on_expired_at", using: :btree
  add_index "bundled_packages", ["package_id"], name: "index_bundled_packages_on_package_id", using: :btree
  add_index "bundled_packages", ["valid_at"], name: "index_bundled_packages_on_valid_at", using: :btree

  create_table "bundles", force: :cascade do |t|
    t.integer  "account_id",                                null: false
    t.string   "name"
    t.string   "path"
    t.string   "platform",                                  null: false
    t.string   "release"
    t.integer  "last_crc",   limit: 8
    t.boolean  "from_api"
    t.datetime "deleted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.datetime "valid_at",             default: "now()",    null: false
    t.datetime "expired_at",           default: 'Infinity', null: false
  end

  add_index "bundles", ["account_id"], name: "index_bundles_on_account_id", using: :btree
  add_index "bundles", ["expired_at"], name: "index_bundles_on_expired_at", using: :btree
  add_index "bundles", ["valid_at"], name: "index_bundles_on_valid_at", using: :btree

  create_table "log_bundle_patches", force: :cascade do |t|
    t.integer  "bundle_id",             null: false
    t.integer  "package_id",            null: false
    t.integer  "bundled_package_id",    null: false
    t.integer  "vulnerability_id",      null: false
    t.integer  "vulnerable_package_id", null: false
    t.datetime "occurred_at",           null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "log_bundle_patches", ["bundle_id", "package_id", "bundled_package_id", "vulnerability_id", "vulnerable_package_id"], name: "index_of_five_kings_LBP", unique: true, using: :btree
  add_index "log_bundle_patches", ["bundle_id"], name: "index_log_bundle_patches_on_bundle_id", using: :btree
  add_index "log_bundle_patches", ["bundled_package_id"], name: "index_log_bundle_patches_on_bundled_package_id", using: :btree
  add_index "log_bundle_patches", ["package_id"], name: "index_log_bundle_patches_on_package_id", using: :btree
  add_index "log_bundle_patches", ["vulnerability_id"], name: "index_log_bundle_patches_on_vulnerability_id", using: :btree
  add_index "log_bundle_patches", ["vulnerable_package_id"], name: "index_log_bundle_patches_on_vulnerable_package_id", using: :btree

  create_table "log_bundle_vulnerabilities", force: :cascade do |t|
    t.integer  "bundle_id",             null: false
    t.integer  "package_id",            null: false
    t.integer  "bundled_package_id",    null: false
    t.integer  "vulnerability_id",      null: false
    t.integer  "vulnerable_package_id", null: false
    t.datetime "occurred_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "log_bundle_vulnerabilities", ["bundle_id", "package_id", "bundled_package_id", "vulnerability_id", "vulnerable_package_id"], name: "index_of_five_kings_LBV", unique: true, using: :btree
  add_index "log_bundle_vulnerabilities", ["bundle_id"], name: "index_log_bundle_vulnerabilities_on_bundle_id", using: :btree
  add_index "log_bundle_vulnerabilities", ["bundled_package_id"], name: "index_log_bundle_vulnerabilities_on_bundled_package_id", using: :btree
  add_index "log_bundle_vulnerabilities", ["package_id"], name: "index_log_bundle_vulnerabilities_on_package_id", using: :btree
  add_index "log_bundle_vulnerabilities", ["vulnerability_id"], name: "index_log_bundle_vulnerabilities_on_vulnerability_id", using: :btree
  add_index "log_bundle_vulnerabilities", ["vulnerable_package_id"], name: "index_log_bundle_vulnerabilities_on_vulnerable_package_id", using: :btree

  create_table "package_archives", force: :cascade do |t|
    t.integer  "package_id",  null: false
    t.string   "name",        null: false
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
    t.datetime "valid_at",    null: false
    t.datetime "expired_at",  null: false
  end

  add_index "package_archives", ["expired_at"], name: "index_package_archives_on_expired_at", using: :btree
  add_index "package_archives", ["package_id"], name: "index_package_archives_on_package_id", using: :btree
  add_index "package_archives", ["valid_at"], name: "index_package_archives_on_valid_at", using: :btree

  create_table "packages", force: :cascade do |t|
    t.string   "name",                             null: false
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
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "valid_at",    default: "now()",    null: false
    t.datetime "expired_at",  default: 'Infinity', null: false
  end

  add_index "packages", ["expired_at"], name: "index_packages_on_expired_at", using: :btree
  add_index "packages", ["name", "version", "platform", "release"], name: "index_packages_on_name_and_version_and_platform_and_release", using: :btree
  add_index "packages", ["valid_at"], name: "index_packages_on_valid_at", using: :btree

  create_table "vulnerabilities", force: :cascade do |t|
    t.string   "package_name",                             null: false
    t.string   "package_platform",                         null: false
    t.string   "title"
    t.datetime "reported_at"
    t.text     "description"
    t.string   "criticality"
    t.text     "patched_versions",    default: [],                      array: true
    t.text     "unaffected_versions", default: [],                      array: true
    t.string   "cve_id"
    t.string   "usn_id"
    t.string   "dsa_id"
    t.string   "rhsa_id"
    t.string   "cesa_id"
    t.string   "source"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.datetime "valid_at",            default: "now()",    null: false
    t.datetime "expired_at",          default: 'Infinity', null: false
  end

  add_index "vulnerabilities", ["expired_at"], name: "index_vulnerabilities_on_expired_at", using: :btree
  add_index "vulnerabilities", ["valid_at"], name: "index_vulnerabilities_on_valid_at", using: :btree

  create_table "vulnerability_archives", force: :cascade do |t|
    t.integer  "vulnerability_id",                 null: false
    t.string   "package_name",                     null: false
    t.string   "package_platform",                 null: false
    t.string   "title"
    t.datetime "reported_at"
    t.text     "description"
    t.string   "criticality"
    t.text     "patched_versions",    default: [],              array: true
    t.text     "unaffected_versions", default: [],              array: true
    t.string   "cve_id"
    t.string   "usn_id"
    t.string   "dsa_id"
    t.string   "rhsa_id"
    t.string   "cesa_id"
    t.string   "source"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "valid_at",                         null: false
    t.datetime "expired_at",                       null: false
  end

  add_index "vulnerability_archives", ["expired_at"], name: "index_vulnerability_archives_on_expired_at", using: :btree
  add_index "vulnerability_archives", ["valid_at"], name: "index_vulnerability_archives_on_valid_at", using: :btree
  add_index "vulnerability_archives", ["vulnerability_id"], name: "index_vulnerability_archives_on_vulnerability_id", using: :btree

  create_table "vulnerable_package_archives", force: :cascade do |t|
    t.integer  "vulnerable_package_id", null: false
    t.integer  "package_id",            null: false
    t.integer  "vulnerability_id",      null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "valid_at",              null: false
    t.datetime "expired_at",            null: false
  end

  add_index "vulnerable_package_archives", ["expired_at"], name: "index_vulnerable_package_archives_on_expired_at", using: :btree
  add_index "vulnerable_package_archives", ["package_id"], name: "index_vulnerable_package_archives_on_package_id", using: :btree
  add_index "vulnerable_package_archives", ["valid_at"], name: "index_vulnerable_package_archives_on_valid_at", using: :btree
  add_index "vulnerable_package_archives", ["vulnerability_id"], name: "index_vulnerable_package_archives_on_vulnerability_id", using: :btree
  add_index "vulnerable_package_archives", ["vulnerable_package_id"], name: "index_vulnerable_package_archives_on_vulnerable_package_id", using: :btree

  create_table "vulnerable_packages", force: :cascade do |t|
    t.integer  "package_id",                            null: false
    t.integer  "vulnerability_id",                      null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "valid_at",         default: "now()",    null: false
    t.datetime "expired_at",       default: 'Infinity', null: false
  end

  add_index "vulnerable_packages", ["expired_at"], name: "index_vulnerable_packages_on_expired_at", using: :btree
  add_index "vulnerable_packages", ["package_id"], name: "index_vulnerable_packages_on_package_id", using: :btree
  add_index "vulnerable_packages", ["valid_at"], name: "index_vulnerable_packages_on_valid_at", using: :btree
  add_index "vulnerable_packages", ["vulnerability_id"], name: "index_vulnerable_packages_on_vulnerability_id", using: :btree

  add_foreign_key "bundled_packages", "bundles"
  add_foreign_key "bundled_packages", "packages"
  add_foreign_key "bundles", "accounts"
  add_foreign_key "vulnerable_packages", "packages"
  add_foreign_key "vulnerable_packages", "vulnerabilities"
end
