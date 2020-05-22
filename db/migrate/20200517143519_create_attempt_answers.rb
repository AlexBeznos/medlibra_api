# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :attempt_answers do
      primary_key :id

      foreign_key :attempt_id, table: :attempts
      foreign_key :answer_id, table: :answers
      foreign_key :question_id, table: :questions
    end
  end
end
