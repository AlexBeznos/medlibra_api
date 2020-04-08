# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :answers do
      primary_key :id

      String :title, null: false
      Boolean :correct, null: false

      foreign_key :question_id, table: :questions
    end
  end
end
