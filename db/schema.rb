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

ActiveRecord::Schema[7.0].define(version: 2025_02_03_030608) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "booking_extensions", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_booking_extensions_on_booking_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "car_id"
    t.integer "driver_id"
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string "ticketable_type", null: false
    t.bigint "ticketable_id", null: false
    t.datetime "issue_date"
    t.decimal "daily_rate"
    t.integer "rental_days"
    t.decimal "subtotal_rent"
    t.decimal "additional_charges", default: "0.0", null: false
    t.decimal "discounts", default: "0.0", null: false
    t.decimal "taxes", default: "0.0", null: false
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticketable_type", "ticketable_id"], name: "index_tickets_on_ticketable"
  end

  add_foreign_key "booking_extensions", "bookings"
end
