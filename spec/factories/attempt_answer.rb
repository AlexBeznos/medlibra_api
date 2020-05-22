# frozen_string_literal: true

Factory.define :attempt_answer do |f|
  f.association(:attempt)
  f.association(:answer)
  f.association(:question)
end
