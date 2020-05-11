# frozen_string_literal: true

Factory.define :answer do |f|
  f.title { fake(:lorem, :word) }
  f.correct { false }
  f.association :question

  f.trait :correct do |a|
    a.correct { true }
  end
end
