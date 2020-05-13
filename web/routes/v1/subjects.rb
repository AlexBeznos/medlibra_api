# frozen_string_literal: true

module Medlibra
  class Web
    route "subjects" do |r|
      r.get Integer, "all" do |id|
        r.resolve_with_handling(
          "transactions.subjects.all",
          uid: env["firebase.uid"],
          id: id,
        )
      end

      r.is do
        r.get do
          r.resolve_with_handling(
            "transactions.subjects.get",
            uid: env["firebase.uid"],
          )
        end
      end
    end
  end
end
