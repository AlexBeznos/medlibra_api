# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "v1/assessment_chunks/:chunk_id", type: :request do
  describe "#GET" do
    it "returns questions" do
      jwt_token, uid = make_jwt_token
      user = Factory[:user, uid: uid]
      subj = Factory[:subfield]
      assessment = Factory[:assessment, :exam]
      expected_answer_keys = Array.new(4) do
        %w[id title isCorrect]
      end
      chunk = Factory[
        :assessment_chunk,
        assessment_id: assessment.id,
        user_id: user.id,
      ]
      questions = Array.new(3) do |i|
        q = if i == 2
              Factory[:question, subfield_id: subj.id]
            else
              Factory[:question]
            end

        Factory[
          :assessment_question,
          assessment_id: assessment.id,
          question_id: q.id
        ]
        Factory[
          :chunk_question,
          assessment_chunk_id: chunk.id,
          question_id: q.id,
        ]

        Array.new(3) do
          Factory[:answer, question_id: q.id]
        end
        Factory[
          :answer,
          :correct,
          question_id: q.id,
        ]
        q
      end

      Factory[
        :bookmark,
        user_id: user.id,
        question_id: questions[1].id,
      ]

      make_request(
        :get,
        "v1/assessment_chunks/#{chunk.id}",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body.count).to eq(3)
      questions.each.with_index do |q, i|
        expect(parsed_body[i]["id"]).to eq(q.id)
        expect(parsed_body[i]["title"]).to eq(q.title)
        expect(parsed_body[i]["answers"].count).to eq(4)
        expect(parsed_body[i]["answers"].map(&:keys)).to eq(expected_answer_keys)

        if i == 1
          expect(parsed_body[i]["bookmarked"]).to eq(true)
        else
          expect(parsed_body[i]["bookmarked"]).to eq(false)
        end

        if i == 2
          expect(parsed_body[i].dig("subject", "id")).to eq(subj.id)
          expect(parsed_body[i].dig("subject", "title")).to eq(subj.name)
        else
          expect(parsed_body[i]["subject"]).to be_nil
        end
      end
    end

    context "when assessment is not related to current user" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]
        assessment_chunk = Factory[:assessment_chunk]

        make_request(
          :get,
          "v1/assessment_chunks/#{assessment_chunk.id}",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "assessment_chunk")).to eq(["is not exist"])
      end
    end

    context "when assessment is not exist" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]

        make_request(
          :get,
          "v1/assessment_chunks/123",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "assessment_chunk")).to eq(["is not exist"])
      end
    end

    context "when user not exist" do
      it "returns error" do
        jwt_token, = make_jwt_token
        assessment_chunk = Factory[:assessment_chunk]

        make_request(
          :get,
          "v1/assessment_chunks/#{assessment_chunk.id}",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end
end
