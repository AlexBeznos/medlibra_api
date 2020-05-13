# frozen_string_literal: true

Factory.define :assessment_question do |f|
  f.association(:question)
  f.association(:assessment)
end
