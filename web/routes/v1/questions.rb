# frozen_string_literal: true

module Medlibra
  class Web
    route "questions" do |r|
      r.get Integer do |assignment_id|
        r.resolve_with_handling(
          "transactions.questions.get",
          uid: env["firebase.uid"],
          id: assignment_id,
          params: r.params,
        )
      end
    end
  end
end
