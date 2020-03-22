# frozen_string_literal: true

Factory.define :krok do |f|
  f.sequence(:name) { |i| "krok-#{i}" }
end
