# frozen_string_literal: true

Factory.define :subfield do |f|
  f.sequence(:name) { |i| "subfield-#{i}" }
end
