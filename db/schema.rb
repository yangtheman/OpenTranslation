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

ActiveRecord::Schema.define(:version => 20100114084048) do

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "origs", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.text     "content"
    t.string   "author"
    t.integer  "origin_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "origs", ["url", "origin_id", "user_id"], :name => "index_orig_posts_on_url_and_origin_id_and_user_id"
  add_index "origs", ["url", "origin_id", "user_id"], :name => "index_origs_on_url_and_origin_id_and_user_id"

  create_table "post_versions", :force => true do |t|
    t.integer  "post_id"
    t.integer  "version"
    t.string   "title"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "origin_id"
    t.integer  "ted_id"
    t.integer  "user_id"
    t.integer  "orig_id"
  end

  add_index "post_versions", ["post_id"], :name => "index_post_versions_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "ted_id"
    t.integer  "user_id"
    t.integer  "orig_id"
  end

  add_index "posts", ["ted_id", "user_id", "orig_id"], :name => "index_posts_on_ted_id_and_user_id_and_orig_post_id"

  create_table "rating_statistics", :force => true do |t|
    t.integer "rated_id"
    t.string  "rated_type"
    t.integer "rating_count"
    t.integer "rating_total", :limit => 10, :precision => 10, :scale => 0
    t.decimal "rating_avg",                 :precision => 10, :scale => 2
    t.integer "rated_ver"
  end

  add_index "rating_statistics", ["rated_type", "rated_id"], :name => "index_rating_statistics_on_rated_type_and_rated_id"

  create_table "ratings", :force => true do |t|
    t.integer "rater_id"
    t.integer "rated_id"
    t.string  "rated_type"
    t.integer "rating",     :limit => 10, :precision => 10, :scale => 0
    t.integer "rated_ver"
  end

  add_index "ratings", ["rated_type", "rated_id"], :name => "index_ratings_on_rated_type_and_rated_id"
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "openid_url"
    t.integer  "fb_user_id", :limit => 8
    t.string   "email_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
