# frozen_string_literal: true

require_relative "db_spec_helper"

require "rack/test"

Dir[SPEC_ROOT.join("support/web/*.rb").to_s].sort.each(&method(:require))
Dir[SPEC_ROOT.join("shared/web/*.rb").to_s].sort.each(&method(:require))

require SPEC_ROOT.join("../system/boot").realpath

RSpec.configure do |config|
  config.include Rack::Test::Methods, type: :request
  config.include Test::WebHelpers
  config.include Shared::Web::TestHelpers, type: :request
  config.include_context "authorization", type: :request

  config.before :suite do
    Test::WebHelpers.app.freeze
  end
end
