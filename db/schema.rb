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

ActiveRecord::Schema.define(version: 2021_02_21_090157) do

  create_table "commands", force: :cascade do |t|
    t.string "name"
    t.integer "meme_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meme_id"], name: "index_commands_on_meme_id"
  end

  create_table "memes", force: :cascade do |t|
    t.string "name"
    t.string "source_url"
    t.string "start"
    t.string "end"
    t.boolean "private"
    t.integer "duration"
    t.float "loudness_i"
    t.float "loudness_lra"
    t.float "loudness_tp"
    t.float "loudness_thresh"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "commands", "memes"
end
