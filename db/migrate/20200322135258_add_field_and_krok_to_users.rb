# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :users do
      add_foreign_key :krok_id, :kroks
      add_foreign_key :field_id, :fields
    end
  end
end
