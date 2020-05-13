# frozen_string_literal: true

require "web_spec_helper"
require "oj"

RSpec.describe "v1/exams", type: :request do
  describe "#GET" do
    it "returns exams by year" do
      jwt_token, uid = make_jwt_token
      krok1 = Factory[:krok]
      field1 = Factory[:field, krok_id: krok1.id]
      krok2 = Factory[:krok]
      field2 = Factory[:field, krok_id: krok2.id]
      years = Array.new(3) { Factory[:year] }
      year4 = Factory[:year]
      Factory[
        :user,
        uid: uid,
        krok_id: krok1.id,
        field_id: field1.id,
      ]

      expected_assessments = years.map.with_index do |year, index|
        Factory[
          :assessment,
          :exam,
          questions_amount: 10 * index,
          krok_id: krok1.id,
          field_id: field1.id,
          year_id: year.id
        ]
      end
      expected_ids = expected_assessments.map(&:id)
      expected_years = years.map(&:name)
      expected_amounts = expected_assessments.map(&:questions_amount)
      Factory[
        :assessment,
        :exam,
        krok_id: krok2.id,
        field_id: field2.id,
        year_id: year4.id
      ]

      make_request(
        :get,
        "v1/exams",
        auth_code: jwt_token,
      )

      expect(last_response).to be_successful
      expect(parsed_body.map { |d| d["id"] }).to eq(expected_ids)
      expect(parsed_body.map { |d| d["year"] }).to eq(expected_years)
      expect(parsed_body.map { |d| d["amount"] }).to eq(expected_amounts)
      expect(parsed_body.map { |d| d["triesAmount"] }).to eq([0, 0, 0])
      expect(parsed_body.map { |d| d["score"] }).to eq([0, 0, 0])
    end

    context "when user is not yet registered" do
      it "returns error" do
        jwt_token, = make_jwt_token
        krok1 = Factory[:krok]
        field1 = Factory[:field, krok_id: krok1.id]
        krok2 = Factory[:krok]
        field2 = Factory[:field, krok_id: krok2.id]
        years = Array.new(3) { Factory[:year] }
        year4 = Factory[:year]
        years.map.with_index do |year, index|
          Factory[
            :assessment,
            :exam,
            questions_amount: 10 * index,
            krok_id: krok1.id,
            field_id: field1.id,
            year_id: year.id
          ]
        end
        Factory[
          :assessment,
          :exam,
          krok_id: krok2.id,
          field_id: field2.id,
          year_id: year4.id
        ]

        make_request(
          :get,
          "v1/exams",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end
end
