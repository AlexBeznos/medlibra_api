# frozen_string_literal: true

Factory.define :assessment do |f|
  f.association :krok
  f.association :field
  f.association :year
  f.questions_amount { rand(10) * 15 }

  f.trait :exam do |d|
    d.type { "exam" }
  end

  f.trait :training do |d|
    d.type { "training" }
    d.association :subfield
  end
end
