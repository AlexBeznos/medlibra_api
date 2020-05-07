# frozen_string_literal: true

module Medlibra
  class Web
    route "exams" do |r|
      r.is do
        r.get do
          r.resolve("transactions.exams.get") do |exams|
            monad = exams.call(uid: env["firebase.uid"])

            if monad.success?
              r.halt(200, monad.success)
            else
              r.halt(422, monad.failure)
            end
          end
        end
      end
    end
  end
end
