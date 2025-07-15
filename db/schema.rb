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

ActiveRecord::Schema[8.0].define(version: 2025_07_15_001132) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.text "description"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "workspace_id", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["workspace_id"], name: "index_categories_on_workspace_id"
  end

  create_table "channel_favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_channel_favorites_on_channel_id"
    t.index ["user_id", "channel_id"], name: "index_channel_favorites_on_user_id_and_channel_id", unique: true
    t.index ["user_id"], name: "index_channel_favorites_on_user_id"
  end

  create_table "channel_members", force: :cascade do |t|
    t.integer "channel_id", null: false
    t.integer "user_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id", "user_id"], name: "index_channel_members_on_channel_id_and_user_id", unique: true
    t.index ["channel_id"], name: "index_channel_members_on_channel_id"
    t.index ["user_id"], name: "index_channel_members_on_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "is_private"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "messages_count", default: 0
    t.integer "channel_members_count", default: 0
    t.integer "workspace_id", null: false
    t.index ["channel_members_count"], name: "index_channels_on_channel_members_count"
    t.index ["created_at"], name: "index_channels_on_created_at"
    t.index ["is_private"], name: "index_channels_on_is_private"
    t.index ["messages_count"], name: "index_channels_on_messages_count"
    t.index ["updated_at"], name: "index_channels_on_updated_at"
    t.index ["workspace_id"], name: "index_channels_on_workspace_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "user_id", null: false
    t.string "commentable_type", null: false
    t.integer "commentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "direct_message_reactions", force: :cascade do |t|
    t.integer "direct_message_id", null: false
    t.integer "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direct_message_id", "user_id", "emoji"], name: "idx_dm_reactions_unique", unique: true
    t.index ["direct_message_id"], name: "index_direct_message_reactions_on_direct_message_id"
    t.index ["user_id"], name: "index_direct_message_reactions_on_user_id"
  end

  create_table "direct_messages", force: :cascade do |t|
    t.text "body"
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.datetime "read_at"
    t.integer "workspace_id", null: false
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_pinned", default: false
    t.datetime "pinned_at"
    t.integer "pinned_by_id"
    t.index ["pinned_by_id"], name: "index_direct_messages_on_pinned_by_id"
    t.index ["read_at"], name: "index_direct_messages_on_read_at"
    t.index ["recipient_id"], name: "index_direct_messages_on_recipient_id"
    t.index ["sender_id", "recipient_id"], name: "index_direct_messages_on_sender_id_and_recipient_id"
    t.index ["sender_id"], name: "index_direct_messages_on_sender_id"
    t.index ["workspace_id"], name: "index_direct_messages_on_workspace_id"
  end

  create_table "message_mentions", force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id"], name: "index_message_mentions_on_message_id_and_user_id", unique: true
    t.index ["message_id"], name: "index_message_mentions_on_message_id"
    t.index ["user_id"], name: "index_message_mentions_on_user_id"
  end

  create_table "message_reactions", force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id", "emoji"], name: "index_message_reactions_on_message_id_and_user_id_and_emoji", unique: true
    t.index ["message_id"], name: "index_message_reactions_on_message_id"
    t.index ["user_id"], name: "index_message_reactions_on_user_id"
  end

  create_table "message_reads", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "message_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_reads_on_message_id"
    t.index ["user_id", "message_id"], name: "index_message_reads_on_user_id_and_message_id", unique: true
    t.index ["user_id"], name: "index_message_reads_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.integer "channel_id", null: false
    t.integer "user_id", null: false
    t.integer "thread_root_id"
    t.integer "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_sample", default: false, null: false
    t.integer "parent_message_id"
    t.boolean "is_pinned", default: false
    t.datetime "pinned_at"
    t.datetime "edited_at"
    t.integer "attached_note_id"
    t.integer "shared_from_message_id"
    t.integer "shared_from_channel_id"
    t.integer "shared_by_user_id"
    t.index ["attached_note_id"], name: "index_messages_on_attached_note_id"
    t.index ["channel_id", "created_at"], name: "index_messages_on_channel_id_and_created_at"
    t.index ["channel_id", "is_pinned"], name: "index_messages_on_channel_id_and_is_pinned"
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["note_id"], name: "index_messages_on_note_id"
    t.index ["parent_message_id"], name: "index_messages_on_parent_message_id"
    t.index ["shared_by_user_id"], name: "index_messages_on_shared_by_user_id"
    t.index ["shared_from_channel_id"], name: "index_messages_on_shared_from_channel_id"
    t.index ["shared_from_message_id"], name: "index_messages_on_shared_from_message_id"
    t.index ["thread_root_id"], name: "index_messages_on_thread_root_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "note_assignees", force: :cascade do |t|
    t.integer "note_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id", "user_id"], name: "index_note_assignees_on_note_id_and_user_id", unique: true
    t.index ["note_id"], name: "index_note_assignees_on_note_id"
    t.index ["user_id"], name: "index_note_assignees_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "category_id", null: false
    t.integer "status_id", null: false
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.date "start_date"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "children_count", default: 0
    t.integer "note_assignees_count", default: 0
    t.integer "position"
    t.boolean "is_sample", default: false, null: false
    t.integer "workspace_id", null: false
    t.index ["category_id"], name: "index_notes_on_category_id"
    t.index ["children_count"], name: "index_notes_on_children_count"
    t.index ["created_at"], name: "index_notes_on_created_at"
    t.index ["due_date"], name: "index_notes_on_due_date"
    t.index ["note_assignees_count"], name: "index_notes_on_note_assignees_count"
    t.index ["parent_id"], name: "index_notes_on_parent_id"
    t.index ["status_id", "position"], name: "index_notes_on_status_id_and_position"
    t.index ["status_id"], name: "index_notes_on_status_id"
    t.index ["updated_at"], name: "index_notes_on_updated_at"
    t.index ["user_id", "category_id"], name: "index_notes_on_user_id_and_category_id"
    t.index ["user_id", "created_at"], name: "index_notes_on_user_id_and_created_at"
    t.index ["user_id", "status_id"], name: "index_notes_on_user_id_and_status_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
    t.index ["workspace_id"], name: "index_notes_on_workspace_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "notification_type", null: false
    t.boolean "read", default: false
    t.integer "priority", default: 1
    t.string "related_type"
    t.bigint "related_id"
    t.string "action_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["related_type", "related_id"], name: "index_notifications_on_related_type_and_related_id"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "saved_direct_messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "direct_message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direct_message_id"], name: "index_saved_direct_messages_on_direct_message_id"
    t.index ["user_id", "direct_message_id"], name: "index_saved_direct_messages_on_user_id_and_direct_message_id", unique: true
    t.index ["user_id"], name: "index_saved_direct_messages_on_user_id"
  end

  create_table "saved_messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_saved_messages_on_message_id"
    t.index ["user_id", "message_id"], name: "index_saved_messages_on_user_id_and_message_id", unique: true
    t.index ["user_id"], name: "index_saved_messages_on_user_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.integer "order"
    t.integer "workflow_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "workspace_id", null: false
    t.integer "position", default: 0
    t.index ["workspace_id", "position"], name: "index_statuses_on_workspace_id_and_position"
    t.index ["workspace_id"], name: "index_statuses_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.string "phone"
    t.string "timezone", default: "Asia/Seoul"
    t.string "language", default: "ko"
    t.string "theme", default: "light"
    t.boolean "email_notifications", default: true
    t.boolean "push_notifications", default: true
    t.integer "notes_count", default: 0
    t.integer "messages_count", default: 0
    t.integer "notifications_count", default: 0
    t.integer "unread_notifications_count", default: 0
    t.string "provider"
    t.string "uid"
    t.string "google_avatar_url"
    t.integer "current_workspace_id"
    t.boolean "marketing_emails", default: false
    t.boolean "browser_notifications", default: true
    t.boolean "quiet_hours", default: false
    t.boolean "admin", default: false
    t.boolean "super_admin", default: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["current_workspace_id"], name: "index_users_on_current_workspace_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["messages_count"], name: "index_users_on_messages_count"
    t.index ["notes_count"], name: "index_users_on_notes_count"
    t.index ["notifications_count"], name: "index_users_on_notifications_count"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["super_admin"], name: "index_users_on_super_admin"
    t.index ["unread_notifications_count"], name: "index_users_on_unread_notifications_count"
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  create_table "workspace_members", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "user_id", null: false
    t.string "role"
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workspace_members_on_user_id"
    t.index ["workspace_id"], name: "index_workspace_members_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "max_members"
    t.integer "max_storage_mb"
    t.boolean "is_active", default: true, null: false
    t.index ["subdomain"], name: "index_workspaces_on_subdomain", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories", "workspaces"
  add_foreign_key "channel_favorites", "channels"
  add_foreign_key "channel_favorites", "users"
  add_foreign_key "channel_members", "channels"
  add_foreign_key "channel_members", "users"
  add_foreign_key "channels", "workspaces"
  add_foreign_key "comments", "users"
  add_foreign_key "direct_message_reactions", "direct_messages"
  add_foreign_key "direct_message_reactions", "users"
  add_foreign_key "direct_messages", "users", column: "pinned_by_id"
  add_foreign_key "direct_messages", "users", column: "recipient_id"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "direct_messages", "workspaces"
  add_foreign_key "message_mentions", "messages"
  add_foreign_key "message_mentions", "users"
  add_foreign_key "message_reactions", "messages"
  add_foreign_key "message_reactions", "users"
  add_foreign_key "message_reads", "messages"
  add_foreign_key "message_reads", "users"
  add_foreign_key "messages", "channels"
  add_foreign_key "messages", "messages", column: "thread_root_id"
  add_foreign_key "messages", "notes"
  add_foreign_key "messages", "notes", column: "attached_note_id"
  add_foreign_key "messages", "users"
  add_foreign_key "note_assignees", "notes"
  add_foreign_key "note_assignees", "users"
  add_foreign_key "notes", "categories"
  add_foreign_key "notes", "notes", column: "parent_id"
  add_foreign_key "notes", "statuses"
  add_foreign_key "notes", "users"
  add_foreign_key "notes", "workspaces"
  add_foreign_key "notifications", "users"
  add_foreign_key "saved_direct_messages", "direct_messages"
  add_foreign_key "saved_direct_messages", "users"
  add_foreign_key "saved_messages", "messages"
  add_foreign_key "saved_messages", "users"
  add_foreign_key "statuses", "workspaces"
  add_foreign_key "users", "workspaces", column: "current_workspace_id"
  add_foreign_key "workspace_members", "users"
  add_foreign_key "workspace_members", "workspaces"
end
