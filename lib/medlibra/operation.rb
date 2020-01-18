# auto_register: false

require "dry/transaction/operation"

module Medlibra
  class Operation
    def self.inherited(subclass)
      subclass.include Dry::Transaction::Operation
    end
  end
end
