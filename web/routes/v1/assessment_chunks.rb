# frozen_string_literal: true

module Medlibra
  class Web
    route "assessment_chunks" do |r|
      r.on Integer do |chunk_id|
        r.get do
          r.resolve_with_handling(
            "transactions.assessment_chunks.get",
            uid: env["firebase.uid"],
            id: chunk_id,
          )
        end
      end
    end
  end
end
