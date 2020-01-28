# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id

      String :username, null: false
      String :uid, null: false, unique: true
      String :learning_intensity, null: false, default: "light"
      Boolean :helper_notifications_enabled, null: false, default: false
      Boolean :changes_notifications_enabled, null: false, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
