# frozen_string_literal: true

module Medlibra
  class Web
    route "exams" do |r|
      r.is do
        r.get do
          r.resolve_with_handling(
            "transactions.exams.get",
            uid: env["firebase.uid"],
          )
        end
      end
    end
  end
end
