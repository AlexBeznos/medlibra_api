# frozen_string_literal: true

require "web_spec_helper"
require "oj"

RSpec.describe "v1/dictionary", type: :request do
  describe "#GET" do
    it "returns krok types with included fields" do
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)
      Factory[:user, uid: uid]
      krok1 = Factory[:krok]
      krok2 = Factory[:krok]
      krok3 = Factory[:krok]
      field_group1 = Array.new(3) { Factory[:field, krok_id: krok1.id] }
      field_group2 = Array.new(3) { Factory[:field, krok_id: krok2.id] }
      field_group3 = Array.new(3) { Factory[:field, krok_id: krok3.id] }
      expected_result = [
        {
          "id" => krok1.id,
          "name" => krok1.name,
          "fields" => field_group1.map do |field|
            {
              "id" => field.id,
              "name" => field.name,
            }
          end,
        },
        {
          "id" => krok2.id,
          "name" => krok2.name,
          "fields" => field_group2.map do |field|
            {
              "id" => field.id,
              "name" => field.name,
            }
          end,
        },
        {
          "id" => krok3.id,
          "name" => krok3.name,
          "fields" => field_group3.map do |field|
            {
              "id" => field.id,
              "name" => field.name,
            }
          end,
        },
      ]

      header "Authorization", "Bearer #{jwt_token}"
      get "v1/dictionary"

      expect(last_response).to be_successful

      result = Oj.load(last_response.body)
      expect(result).not_to be_empty
      expect(result).to eq(expected_result)
    end
  end
end
