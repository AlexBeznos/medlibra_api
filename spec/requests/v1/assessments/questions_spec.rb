# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "v1/assessments/:assessment_id/questions", type: :request do
  describe "#GET" do
    it "returns questions" do
      jwt_token, uid = make_jwt_token
      user = Factory[:user, uid: uid]
      assessment = Factory[:assessment, :exam]
      subfield = Factory[:subfield]
      question_answers = Array.new(3) do |index|
        question =
          if index.zero?
            Factory[:question, subfield_id: subfield.id]
          else
            Factory[:question]
          end

        Factory[
          :assessment_question,
          question_id: question.id,
          assessment_id: assessment.id,
        ]

        [
          question,
          Array.new(3) { Factory[:answer, question: question] } +
            [Factory[:answer, :correct, question: question]],
        ]
      end
      Factory[
        :bookmark,
        question_id: question_answers[1].first.id,
        user_id: user.id,
      ]

      make_request(
        :get,
        "v1/assessments/#{assessment.id}/questions",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body["hasNext"]).to eq(false)
      expect(parsed_body["hasPrev"]).to eq(false)

      question_answers.each.with_index do |(question, answers), index|
        expected_answers = answers.map do |answer|
          {
            "id" => answer.id,
            "title" => answer.title,
            "isCorrect" => answer.correct,
          }
        end
        expected_question = {
          "id" => question.id,
          "title" => question.title,
          "answers" => expected_answers,
          "bookmarked" => index == 1,
          "subject" => nil,
        }

        if index.zero?
          expected_question["subject"] = {
            "id" => subfield.id,
            "title" => subfield.name,
          }
        end

        expect(parsed_body.dig("questions", index))
          .to eq(expected_question)
      end
    end

    it "paginatable" do
      jwt_token, uid = make_jwt_token
      Factory[:user, uid: uid]
      assessment = Factory[:assessment, :exam]
      question_answers = Array.new(3) do
        question = Factory[:question]
        Factory[
          :assessment_question,
          question_id: question.id,
          assessment_id: assessment.id,
        ]

        [
          question,
          Array.new(3) { Factory[:answer, question: question] } +
            [Factory[:answer, :correct, question: question]],
        ]
      end

      make_request(
        :get,
        "v1/assessments/#{assessment.id}/questions",
        auth_code: jwt_token,
        params: { limit: 2, offset: 0 },
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body["hasNext"]).to eq(true)
      expect(parsed_body["hasPrev"]).to eq(false)
      expect(parsed_body["questions"].count).to eq(2)

      ids = parsed_body["questions"].map { |q| q["id"] }
      expected_ids =
        question_answers[0..1].map do |(q, _)|
          q.id
        end

      expect(ids).to eq(expected_ids)

      make_request(
        :get,
        "v1/assessments/#{assessment.id}/questions",
        auth_code: jwt_token,
        params: { limit: 2, offset: 2 },
      )

      reload_parsed_body!

      expect(last_response.status).to eq(200)
      expect(parsed_body["hasNext"]).to eq(false)
      expect(parsed_body["hasPrev"]).to eq(true)
      expect(parsed_body["questions"].count).to eq(1)

      ids = parsed_body["questions"].map { |q| q["id"] }
      expected_ids = [question_answers.last.first.id]

      expect(ids).to eq(expected_ids)
    end

    context "when limit too big" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]
        assessment = Factory[:assessment, :exam]

        make_request(
          :get,
          "v1/assessments/#{assessment.id}/questions",
          auth_code: jwt_token,
          params: { limit: 12, offset: 2 },
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "limit"))
          .to eq(["must be less than or equal to 10"])
      end
    end

    context "when assessment is not exist" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]

        make_request(
          :get,
          "v1/assessments/1/questions",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "assessment")).to eq(["is not exist"])
      end
    end

    context "when user not exist" do
      it "returns error" do
        jwt_token, = make_jwt_token
        assessment = Factory[:assessment, :exam]

        make_request(
          :get,
          "v1/assessments/#{assessment.id}/questions",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end
end
