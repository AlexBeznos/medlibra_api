# frozen_string_literal: true

Factory.define :question do |f|
  f.title { Faker::Lorem.sentence }

  f.trait :with_relation do |q|
    q.association(:assessment_questions)
  end
end
