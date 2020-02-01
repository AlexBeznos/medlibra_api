# frozen_string_literal: true

# auto_register: false

require "rom-repository"
require "medlibra/container"
require "medlibra/import"

module Medlibra
  class Repository < ROM::Repository::Root
    include Import.args["persistence.rom"]
  end
end
