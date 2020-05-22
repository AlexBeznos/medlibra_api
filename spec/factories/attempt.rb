# frozen_string_literal: true

Factory.define :attempt do |f|
  f.score { 0.1 }
  f.association(:assessment)
  f.association(:user)
  f.created_at { Time.now }
  f.updated_at { Time.now }
end
