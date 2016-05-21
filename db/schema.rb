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

ActiveRecord::Schema.define(version: 20160520174805) do

  create_table "package_sets", force: :cascade do |t|
    t.integer  "pallet_id"
    t.integer  "package_id"
    t.boolean  "vulnerable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "kind"
    t.string   "version"
    t.string   "artifact"
    t.string   "platform"
    t.string   "epoch"
    t.string   "arch"
    t.string   "filename"
    t.string   "checksum"
    t.string   "origin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pallets", force: :cascade do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "path"
    t.string   "kind"
    t.string   "release"
    t.integer  "last_crc",   limit: 8
    t.boolean  "from_api"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "vulnerabilities", force: :cascade do |t|
    t.integer  "package_id"
    t.string   "title"
    t.datetime "reported_at"
    t.text     "description"
    t.string   "criticality"
    t.string   "cve_id"
    t.string   "usn_id"
    t.string   "dsa_id"
    t.string   "rhsa_id"
    t.string   "cesa_id"
    t.string   "source"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
