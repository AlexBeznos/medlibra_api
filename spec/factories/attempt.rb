# frozen_string_literal: true

Factory.define :attempt do |f|
  f.score { 0.1 }
  f.association(:assessment)
  f.association(:user)
end
