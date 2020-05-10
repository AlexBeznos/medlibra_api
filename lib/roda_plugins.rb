# frozen_string_literal: true

require "roda"

class Roda
  module RodaPlugins
    module Resolver
      module RequestMethods
        def resolve_with_handling(*args)
          transaction = args.shift

          resolve(transaction) do |tr|
            result = tr.(*args)

            if result.success?
              success(result)
            else
              halt(422, errors: result.failure)
            end
          end
        end

        def success(result)
          if result.success.to_s == "Unit"
            halt(200)
          else
            halt(200, result.success)
          end
        end
      end
    end

    register_plugin :resolver, Resolver
  end
end
