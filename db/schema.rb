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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120110114800) do

  create_table "artefacts", :force => true do |t|
    t.string   "section"
    t.string   "name",                                   :null => false
    t.string   "slug",                                   :null => false
    t.string   "kind",                                   :null => false
    t.string   "owning_app",                             :null => false
    t.boolean  "active",              :default => false, :null => false
    t.string   "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "need_id"
    t.string   "department"
    t.integer  "contact_id"
    t.string   "fact_checkers"
    t.integer  "related_items_count", :default => 0
    t.boolean  "relatedness_done",    :default => false
    t.string   "publication_id"
  end

  add_index "artefacts", ["name"], :name => "index_artefacts_on_name"
  add_index "artefacts", ["need_id"], :name => "index_artefacts_on_need_id"

  create_table "artefacts_audiences", :id => false, :force => true do |t|
    t.integer "artefact_id", :null => false
    t.integer "audience_id", :null => false
  end

  add_index "artefacts_audiences", ["artefact_id"], :name => "index_artefacts_audiences_on_artefact_id"
  add_index "artefacts_audiences", ["audience_id"], :name => "index_artefacts_audiences_on_audience_id"

  create_table "audiences", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "name",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "postal_address"
    t.string   "email_address"
    t.string   "website_url"
    t.text     "opening_hours"
    t.integer  "contactotron_id", :null => false
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer  "contact_id", :null => false
    t.string   "kind",       :null => false
    t.string   "label"
    t.string   "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "related_items", :force => true do |t|
    t.integer "source_artefact_id", :null => false
    t.integer "artefact_id",        :null => false
    t.integer "sort_key",           :null => false
  end

  add_index "related_items", ["artefact_id"], :name => "index_related_items_on_artefact_id"
  add_index "related_items", ["sort_key"], :name => "index_related_items_on_sort_key"
  add_index "related_items", ["source_artefact_id"], :name => "index_related_items_on_source_artefact_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.integer  "version"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
