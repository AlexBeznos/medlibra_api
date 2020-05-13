# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :questions do
      primary_key :id

      String :title, null: false

      foreign_key :subfield_id, table: :subfields
    end
  end
end
