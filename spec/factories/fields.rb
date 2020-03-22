# frozen_string_literal: true

Factory.define :field do |f|
  f.sequence(:name) { |i| "field-#{i}" }

  f.association(:krok)
end
