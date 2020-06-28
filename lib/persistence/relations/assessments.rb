# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Assessments < ROM::Relation[:sql]
      schema(:assessments, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :type, ::Types::AssessmentTypes
        attribute :questions_amount, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :krok
          belongs_to :field
          belongs_to :subfield
          belongs_to :year

          has_many :assessment_questions
          has_many :questions, through: :assessment_questions
          has_many :attempts
        end
      end

      def exams_page(krok_id:, field_id:)
        where(type: ::Types::AssessmentTypes["exam"])
          .where(krok_id: krok_id)
          .where(field_id: field_id)
      end

      def subfields_page(krok_id:, field_id:, subfield_id:)
        where(type: ::Types::AssessmentTypes["training"])
          .where(krok_id: krok_id)
          .where(field_id: field_id)
          .where(subfield_id: subfield_id)
      end

      def with_attempts_by_user(user_id:)
        combine(:year, :attempts)
          .node(:attempts) do |attempts|
            attempts
              .where(user_id: user_id)
              .select(:score, :assessment_id)
              .order { created_at.desc }
          end
      end
    end
  end
end
