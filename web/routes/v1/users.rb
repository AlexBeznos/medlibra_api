# frozen_string_literal: true

module Medlibra
  class Web
    route "users" do |r| # rubocop:disable Metrics/BlockLength
      r.is do
        r.post do
          r.resolve "transactions.users.create" do |create|
            result = create.(
              params: r.params.merge(uid: r.env["firebase.uid"]),
            )

            if result.success?
              r.halt(200)
            else
              r.halt(422, errors: result.failure)
            end
          end
        end

        r.put do
          r.resolve "transactions.users.update" do |create|
            result = create.(
              params: r.params,
              uid: r.env["firebase.uid"],
            )

            if result.success?
              r.halt(200)
            else
              r.halt(422, errors: result.failure)
            end
          end
        end
      end
    end
  end
end
