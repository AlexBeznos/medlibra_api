require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    module Users
      class ForCreate < Dry::Validation::Contract
        option :users_repo, default: -> { Medlibra::Container["repositories.users_repo"] }

        json do
          required(:username).value(:string)
          required(:uid).value(:string)
        end
        
        rule(:uid) do
          if users_repo.users.exist?(uid: values[:uid])
            key.failure("already exists") 
          end
        end
      end
    end
  end
end

