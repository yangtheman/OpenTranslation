# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090910192359) do

  create_table "languages", :force => true do |t|
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short"
  end

  create_table "post_versions", :force => true do |t|
    t.integer  "post_id"
    t.integer  "version"
    t.string   "url"
    t.string   "title"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "origin_id"
    t.integer  "ted_id"
  end

  add_index "post_versions", ["post_id"], :name => "index_post_versions_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "origin_id"
    t.integer  "ted_id"
  end

end
