# frozen_string_literal: true

require "dry/monads"
require "medlibra/import"

module Medlibra
  module Services
    class PaginationMeta
      def call(query, limit:, offset:)
        {
          hasNext: next?(query, limit, offset),
          hasPrev: prev?(query, limit, offset),
        }
      end

      private

      def next?(query, limit, offset)
        query
          .limit(limit)
          .offset(limit + offset)
          .exist?
      end

      def prev?(query, limit, offset)
        return false if offset.zero?

        query
          .limit(limit)
          .offset(limit - offset)
          .exist?
      end
    end
  end
end
