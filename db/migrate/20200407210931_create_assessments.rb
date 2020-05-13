# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :assessments do
      primary_key :id

      String :type, null: false
      Integer :questions_amount, null: false

      foreign_key :krok_id, table: :kroks
      foreign_key :field_id, table: :fields
      foreign_key :subfield_id, table: :subfields
      foreign_key :year_id, table: :years

      index(
        %i[type krok_id field_id year_id],
      )
      index(
        %i[type krok_id field_id subfield_id year_id],
      )
    end
  end
end
