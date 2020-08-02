# frozen_string_literal: true

Factory.define :chunk_question do |f|
  f.association(:assessment_chunk)
  f.association(:question)
end
