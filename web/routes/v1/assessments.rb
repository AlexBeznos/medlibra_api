# frozen_string_literal: true

module Medlibra
  class Web
    route "assessments" do |r| # rubocop:disable Metrics/BlockLength
      r.on Integer do |assessment_id|
        r.get "questions" do
          r.resolve_with_handling(
            "transactions.questions.get",
            uid: env["firebase.uid"],
            id: assessment_id,
            params: r.params,
          )
        end

        r.post "finish" do
          r.resolve_with_handling(
            "transactions.attempts.create",
            uid: env["firebase.uid"],
            id: assessment_id,
            params: r.POST,
          )
        end

        r.post "chunks" do
          r.resolve_with_handling(
            "transactions.assessment_chunks.create",
            uid: env["firebase.uid"],
            id: assessment_id,
            params: r.POST,
          )
        end
      end
    end
  end
end
