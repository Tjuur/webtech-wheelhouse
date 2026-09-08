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

ActiveRecord::Schema[8.0].define(version: 2026_09_08_154657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bikes", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "make", null: false
    t.string "model", null: false
    t.string "colour", null: false
    t.string "serial_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["serial_number"], name: "index_bikes_on_serial_number", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repair_services", force: :cascade do |t|
    t.bigint "repair_id", null: false
    t.bigint "service_id", null: false
    t.decimal "charged_price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repairs", force: :cascade do |t|
    t.bigint "bike_id", null: false
    t.bigint "staff_id"
    t.string "status", default: "Received", null: false
    t.string "approval_status"
    t.date "promised_on"
    t.datetime "quoted_at"
    t.datetime "handed_back_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "current_price", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "staffs", force: :cascade do |t|
    t.string "name", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
