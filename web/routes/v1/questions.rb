# frozen_string_literal: true

module Medlibra
  class Web
    route "questions" do |r|
      r.on Integer do |assessment_id|
        r.get do
          r.resolve_with_handling(
            "transactions.questions.get",
            uid: env["firebase.uid"],
            id: assessment_id,
            params: r.params,
          )
        end

        r.post "finish" do
          r.resolve_with_handling(
            "transactions.questions.finish",
            uid: env["firebase.uid"],
            id: assessment_id,
            params: r.POST,
          )
        end
      end
    end
  end
end
