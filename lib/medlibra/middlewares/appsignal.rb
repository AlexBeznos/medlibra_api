# frozen_string_literal: true

require "appsignal"
require "medlibra/container"

module Medlibra
  module Middlewares
    class Appsignal < Appsignal::Rack::GenericInstrumentation
      def call(env)
        name = make_endpoint_name(env)
        Container["monitor.appsignal"].set_action(name)
        super(env)
      end

      private

      def make_endpoint_name(env)
        method = env["REQUEST_METHOD"]
        path = env["REQUEST_PATH"].gsub(%r{/\d+}, "/:id")

        "#{method} #{path}"
      end
    end
  end
end
