# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :chunk_questions do
      primary_key :id

      foreign_key :assessment_chunk_id, table: :assessment_chunks
      foreign_key :question_id, table: :questions
    end
  end
end
