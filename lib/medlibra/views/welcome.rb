require "medlibra/view"

module Medlibra
  module Views
    class Welcome < Medlibra::View
      configure do |config|
        config.template = "welcome"
      end
    end
  end
end
