# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"
require "types"

module Medlibra
  module Validations
    module Users
      class ForUpdate < Dry::Validation::Contract
        option(
          :kroks_repo,
          default: lambda do
            Medlibra::Container["repositories.kroks_repo"]
          end,
        )
        option(
          :fields_repo,
          default: lambda do
            Medlibra::Container["repositories.fields_repo"]
          end,
        )

        json do
          optional(:krok_id).filled(:integer)
          optional(:field_id).filled(:integer)
          optional(:helper_notifications_enabled).filled(:bool)
          optional(:changes_notifications_enabled).filled(:bool)
          optional(:learning_intensity).value(::Types::LearningIntensities)
        end

        rule(:krok_id) do
          key.failure("not exist") if key? && !krok_exist?(values[:krok_id])
        end

        rule(:field_id) do
          if key?
            if values[:krok_id]
              unless field_exist?(values[:krok_id], values[:field_id])
                key.failure("not exist")
              end
            else
              key.failure("krok_id is required") unless values[:krok_id]
            end
          end
        end

        def krok_exist?(krok_id)
          kroks_repo
            .kroks
            .exist?(id: krok_id)
        end

        def field_exist?(krok_id, field_id)
          fields_repo
            .fields
            .where(id: field_id, krok_id: krok_id)
            .one
        end
      end
    end
  end
end
