# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :assessment_questions do
      primary_key :id

      foreign_key :question_id, table: :questions
      foreign_key :assessment_id, table: :assessments
    end
  end
end
