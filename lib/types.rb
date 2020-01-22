require "dry/struct"
require "dry/types"

module Types
  include Dry.Types()

  LearningIntensities = Types::Strict::String.enum(
    'light',
    'normal',
    'hard',
  )
end
