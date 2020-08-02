# frozen_string_literal: true

Factory.define :assessment_chunk do |f|
  f.association :assessment, :exam
  f.association :user
  f.created_at { Time.now.utc }
  f.updated_at { Time.now.utc }
end
