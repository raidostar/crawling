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

ActiveRecord::Schema.define(version: 2019_04_17_050717) do

  create_table "daily_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date"
    t.integer "platform_id"
    t.string "advertiser_id"
    t.string "advertiser_name"
    t.integer "group_advertiser_id"
    t.string "order_id"
    t.string "order_name"
    t.integer "group_order_id"
    t.string "schedule_id"
    t.string "schedule_name"
    t.string "creative_id"
    t.string "creative_name"
    t.text "creative_image_url"
    t.text "click_url"
    t.integer "imp"
    t.integer "click"
    t.integer "cv"
    t.decimal "gross", precision: 10
    t.decimal "net", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version"
  end

end
