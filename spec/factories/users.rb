# frozen_string_literal: true

require "securerandom"

Factory.define :user do |f|
  f.association :krok
  f.association :field

  f.sequence(:username) { |i| "username-#{i}" }
  f.uid { SecureRandom.hex }
  f.created_at { Time.now }
  f.updated_at { Time.now }
end
