# frozen_string_literal: true

require "web_spec_helper"
require "oj"

RSpec.describe "v1/dictionary", type: :request do
  describe "#GET" do
    it "returns krok types with included fields" do
      jwt_token, uid = make_jwt_token
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

      make_request(
        :get,
        "v1/dictionary",
        auth_code: jwt_token,
      )

      expect(last_response).to be_successful
      expect(parsed_body).not_to be_empty
      expect(parsed_body).to eq(expected_result)
    end
  end
end
