# frozen_string_literal: true

Factory.define :bookmark do |f|
  f.association(:user)
  f.association(:question)
  f.created_at { Time.now }
  f.updated_at { Time.now }
end
