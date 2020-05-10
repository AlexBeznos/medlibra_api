# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Bookmarks < ROM::Relation[:sql]
      schema(:bookmarks, infer: true) do
        attribute :id, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :user
          belongs_to :question
        end
      end

      def bookmarks_page(user)
        where(user_id: user.id)
          .combine(
            question: {
              assessments: %i[
                year
                subfield
              ],
            },
          ).order { created_at.desc }
      end
    end
  end
end
