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

ActiveRecord::Schema.define(version: 2022_02_04_114101) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "sanctioned_entities", force: :cascade do |t|
    t.integer "list_id", null: false
    t.integer "parent_id"
    t.string "full_name", null: false
    t.string "entity_type", null: false
    t.string "sanction_program"
    t.string "authority"
    t.string "title"
    t.text "remarks"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["full_name"], name: "index_sanctioned_entities_on_full_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["list_id", "authority"], name: "index_sanctioned_entities_on_list_id_and_authority", unique: true
  end

end
