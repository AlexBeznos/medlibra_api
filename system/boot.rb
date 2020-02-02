# frozen_string_literal: true

require "bundler/setup"

begin
  require "pry-byebug"
rescue LoadError
end

require_relative "medlibra/container"

Medlibra::Container.finalize!

require "medlibra/web"
