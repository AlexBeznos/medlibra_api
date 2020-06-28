# frozen_string_literal: true

require "roda"
require "dry/monads/unit"
require "medlibra/container"

class Roda
  module RodaPlugins
    module Resolver
      module RequestMethods
        def resolve_with_handling(transaction, **params)
          resolve(transaction) do |tr|
            result = with_instrument("transaction.#{transaction}") { tr.(**params) }

            if result.success?
              success(result)
            else
              halt(422, errors: result.failure)
            end
          end
        end

        def success(result)
          case result.success
          when Dry::Monads::Unit
            halt(201)
          when Integer
            halt(result.success)
          else
            halt(200, result.success)
          end
        end

        private

        def with_instrument(name)
          Medlibra::Container["monitor.appsignal"].instrument(name) do
            yield
          end
        end
      end
    end

    register_plugin :resolver, Resolver
  end
end
