# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Bookmarks
      class Get
        DEFAULT_LIMIT = 10
        DEFAULT_OFFSET = 0

        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.bookmarks_repo",
          "services.find_user",
          "services.pagination_meta",
          validate: "validations.for_pagination",
        ]

        def call(uid:, params:)
          user = yield find_user.(uid)
          params = yield validate_params(params)
          meta = get_pagination_meta(user, params)
          questions = get_questions(user, **params)

          Success([200, meta.merge(questions: questions)])
        end

        private

        def validate_params(params)
          result = validate.(params)
          return Failure(result.errors.to_h) if result.failure?

          params = result.values.to_h

          Success(
            limit: params.fetch(:limit, DEFAULT_LIMIT),
            offset: params.fetch(:offset, DEFAULT_OFFSET),
          )
        end

        def get_pagination_meta(user, params)
          query =
            bookmarks_repo
            .bookmarks
            .where(user_id: user.id)

          pagination_meta
            .call(query, **params)
        end

        def get_questions(user, limit:, offset:)
          bookmarks =
            bookmarks_repo
            .bookmarks
            .bookmarks_page(user)
            .limit(limit)
            .offset(offset)

          serialize_questions(bookmarks.to_a)
        end

        def serialize_questions(bookmarks) # rubocop:disable Metrics/AbcSize
          bookmarks.map do |bookmark|
            {
              id: bookmark.question.id,
              title: bookmark.question.title,
              year: bookmark.question.assessments.year.name,
              subfield: bookmark.question.assessments.subfield&.name,
              type: bookmark.question.assessments.type,
              answer: bookmark.question.answers.first.title,
            }
          end
        end
      end
    end
  end
end
