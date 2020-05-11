# frozen_string_literal: true

require "web_spec_helper"
require "oj"

RSpec.describe "v1/subjects/:id/all", type: :request do
  describe "#GET" do
    it "returns training and exam" do
      jwt_token, uid = make_jwt_token
      krok = Factory[:krok]
      field = Factory[:field]
      Factory[
        :user,
        uid: uid,
        krok: krok,
        field: field,
      ]
      year = Factory[:year]
      subfield = Factory[:subfield]
      training = Factory[
        :assessment,
        :training,
        krok: krok,
        field: field,
        year: year,
        subfield: subfield,
      ]
      exam = Factory[
        :assessment,
        :training_exam,
        krok: krok,
        field: field,
        year: year,
        subfield: subfield,
      ]

      expected_exam = {
        "id" => exam.id,
        "amount" => exam.questions_amount,
      }
      expected_training = {
        "id" => training.id,
        "amount" => training.questions_amount,
      }

      make_request(
        :get,
        "v1/subjects/#{subfield.id}/all",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body.count).to eq(1)
      expect(parsed_body[0]["exam"]).to eq(expected_exam)
      expect(parsed_body[0]["training"]).to eq(expected_training)
      expect(parsed_body[0]["year"]).to eq(year.name)
      expect(parsed_body[0]["triesAmount"]).to eq(0)
      expect(parsed_body[0]["score"]).to eq(0)
    end

    context "when subfield is not exist" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[
          :user,
          uid: uid,
        ]

        make_request(
          :get,
          "v1/subjects/1/all",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "subject")).to eq(["is not exist"])
      end
    end

    context "when user is not yet registered" do
      it "returns error" do
        jwt_token, = make_jwt_token
        subfield = Factory[:subfield]

        make_request(
          :get,
          "v1/subjects/#{subfield.id}/all",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end
end
