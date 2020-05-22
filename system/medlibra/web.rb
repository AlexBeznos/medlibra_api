# frozen_string_literal: true

require "dry/web/roda/application"
require "roda_plugins"
require_relative "container"

module Medlibra
  class Web < Dry::Web::Roda::Application
    configure do |config|
      config.container = Container
      config.routes = "web/routes"
    end

    opts[:root] = Pathname(__FILE__).join("../..").realpath.dirname

    use Container["middlewares.auth"].class

    plugin :error_handler
    plugin :json
    plugin :json_parser, parser: Container["services.parse_request_body"]
    plugin :halt
    plugin :multi_route
    plugin :all_verbs
    plugin :resolver

    route do |r|
      r.on "v1" do
        r.multi_route
      end
    end

    error do |e|
      self.class[:rack_monitor].instrument(
        :error,
        exception: e,
        uid: env["firebase.uid"],
      )

      raise e if ENV["RACK_ENV"] != "production"

      { errors: ["something went wrong..."] }
    end

    load_routes!
  end
end
