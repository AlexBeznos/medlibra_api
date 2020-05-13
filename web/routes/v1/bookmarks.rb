# frozen_string_literal: true

module Medlibra
  class Web
    route "bookmarks" do |r|
      r.is do
        r.get do
          r.resolve_with_handling(
            "transactions.bookmarks.get",
            params: r.params,
            uid: r.env["firebase.uid"],
          )
        end
        r.post do
          r.resolve_with_handling(
            "transactions.bookmarks.create",
            params: r.params,
            uid: r.env["firebase.uid"],
          )
        end
      end
    end
  end
end
