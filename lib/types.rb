# frozen_string_literal: true

require "dry/struct"
require "dry/types"

module Types
  include Dry.Types()

  LearningIntensities = Types::Strict::String.enum(
    "light",
    "normal",
    "hard",
  )
  AssessmentTypes = Types::Strict::String.enum(
    "exam",
    "training",
    "training-exam",
  )
end
