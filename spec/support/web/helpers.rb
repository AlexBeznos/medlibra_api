# frozen_string_literal: true

module Test
  module WebHelpers
    module_function

    def app
      Medlibra::Web.app
    end
  end
end
