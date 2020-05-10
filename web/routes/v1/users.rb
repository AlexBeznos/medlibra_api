# frozen_string_literal: true

module Medlibra
  class Web
    route "users" do |r|
      r.is do
        r.post do
          r.resolve_with_handling(
            "transactions.users.create",
            params: r.params.merge(uid: r.env["firebase.uid"]),
          )
        end

        r.put do
          r.resolve_with_handling(
            "transactions.users.update",
            uid: env["firebase.uid"],
            params: r.params,
          )
        end
      end
    end
  end
end
