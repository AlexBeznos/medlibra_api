# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :fields do
      primary_key :id

      String :name, null: false

      foreign_key :krok_id, table: :kroks
    end
  end
end
