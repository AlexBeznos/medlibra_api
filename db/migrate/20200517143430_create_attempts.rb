# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :attempts do
      primary_key :id

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      Float :score, null: false

      foreign_key :assessment_id, table: :assessments
      foreign_key :user_id, table: :users
    end
  end
end
