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

<<<<<<< ec6bb27e8f459ad39e89b10bd2f7c258157b8e6f
ActiveRecord::Schema.define(version: 20_170_427_124_906) do
=======
ActiveRecord::Schema.define(version: 20170510060126) do

>>>>>>> Added organizations and contacts resources
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

<<<<<<< ec6bb27e8f459ad39e89b10bd2f7c258157b8e6f
  create_table 'organizations', force: :cascade do |t|
    t.string   'name'
    t.text     'description'
    t.datetime 'created_at',  null: false
    t.datetime 'updated_at',  null: false
=======
  create_table "clients", force: :cascade do |t|
    t.string "email"
    t.string "uuid"
    t.string "key"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
>>>>>>> Added organizations and contacts resources
  end

  create_table 'organizations_users', id: false, force: :cascade do |t|
    t.integer 'organization_id'
    t.integer 'user_id'
    t.index ['organization_id'], name: 'index_organizations_users_on_organization_id', using: :btree
    t.index ['user_id'], name: 'index_organizations_users_on_user_id', using: :btree
  end

<<<<<<< ec6bb27e8f459ad39e89b10bd2f7c258157b8e6f
  create_table 'user_types', force: :cascade do |t|
    t.string   'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string   'email'
    t.string   'password_digest'
    t.integer  'user_type_id'
    t.datetime 'created_at',      null: false
    t.datetime 'updated_at',      null: false
    t.index ['user_type_id'], name: 'index_users_on_user_type_id', using: :btree
=======
  create_table "user_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.date     "date_of_birth"
    t.string   "avatar_url"
    t.integer  "user_type_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["user_type_id"], name: "index_users_on_user_type_id", using: :btree
>>>>>>> Added organizations and contacts resources
  end
end
