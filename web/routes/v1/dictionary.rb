# frozen_string_literal: true

module Medlibra
  class Web
    route "dictionary" do |r|
      r.is do
        r.get do
          r.resolve(
            "transactions.dictionary.get",
            &:call
          )
        end
      end
    end
  end
end
