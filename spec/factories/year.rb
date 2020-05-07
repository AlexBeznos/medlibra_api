# frozen_string_literal: true

Factory.define :year do |f|
  f.sequence(:name) { |i| "200#{i}" }
end
