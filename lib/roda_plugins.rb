# frozen_string_literal: true

require "roda"
require "dry/monads"
require "medlibra/container"

class Roda
  module RodaPlugins
    module Resolver
      module RequestMethods
        include Dry::Monads[:result]

        def resolve_with_handling(transaction, **params) # rubocop:disable AbcSize/MethodLength
          resolve(transaction) do |tr|
            result = with_instrument(transaction) { tr.(**params) }

            case result
            in Success(Integer => code)
              halt(code)
            in Success[Integer => code, result]
              halt(code, result)
            in Success()
              halt(201)
            in Failure(errors)
              halt(422, errors: errors)
            in Failure()
              halt(500)
            end
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
