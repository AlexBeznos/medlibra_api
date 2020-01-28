require "dry/web/roda/application"
require_relative "container"

module Medlibra
  class Web < Dry::Web::Roda::Application
    configure do |config|
      config.container = Container
      config.routes = "web/routes".freeze
    end

    opts[:root] = Pathname(__FILE__).join("../..").realpath.dirname

    use Container['middlewares.auth'].class

    plugin :error_handler
    plugin :json
    plugin :json_parser
    plugin :halt
    plugin :multi_route
    plugin :all_verbs

    route do |r|
      r.multi_route
    end

    error do |e|
      self.class[:rack_monitor].instrument(:error, exception: e)
      raise e
    end

    load_routes!
  end
end
