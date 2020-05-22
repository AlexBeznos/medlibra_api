# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "v1/questions/:assessment_id/finish", type: :request do
  describe "#GET" do
    context "when all answers correct" do
      it "creates attempt with score 1" do
        jwt_token, uid = make_jwt_token
        user = Factory[:user, uid: uid]
        data = prepare_data
        body = data[:question_answers].map do |qa|
          {
            questionId: qa[:question].id,
            choosenAnswerId: qa[:answers].last.id,
          }
        end

        make_request(
          :post,
          "v1/questions/#{data[:assessment].id}/finish",
          auth_code: jwt_token,
          params: body,
        )

        expect(last_response.status).to eq(201)
        attempts = attempts_repo.attempts.to_a
        expect(attempts.count).to eq(1)
        attempt = attempts.first
        expect(attempt.score).to eq(1)
        expect(attempt.assessment_id).to eq(data[:assessment].id)
        expect(attempt.user_id).to eq(user.id)

        aas = attempt_answers_repo.attempt_answers.to_a
        body.each do |ans_body|
          aa = aas.find { |a| a.question_id == ans_body[:questionId] }

          expect(aa.answer_id).to eq(ans_body[:choosenAnswerId])
          expect(aa.attempt_id).to eq(attempt.id)
        end
      end
    end

    context "when half answers are correct" do
      it "creates attempt with score 0.5" do
        jwt_token, uid = make_jwt_token
        user = Factory[:user, uid: uid]
        data = prepare_data
        body = data[:question_answers].map.with_index do |qa, i|
          ans = i.odd? ? :first : :last

          {
            questionId: qa[:question].id,
            choosenAnswerId: qa[:answers].public_send(ans).id,
          }
        end

        make_request(
          :post,
          "v1/questions/#{data[:assessment].id}/finish",
          auth_code: jwt_token,
          params: body,
        )

        expect(last_response.status).to eq(201)
        attempts = attempts_repo.attempts.to_a
        expect(attempts.count).to eq(1)
        attempt = attempts.first
        expect(attempt.score).to eq(0.5)
        expect(attempt.assessment_id).to eq(data[:assessment].id)
        expect(attempt.user_id).to eq(user.id)

        aas = attempt_answers_repo.attempt_answers.to_a
        body.each do |ans_body|
          aa = aas.find { |a| a.question_id == ans_body[:questionId] }

          expect(aa.answer_id).to eq(ans_body[:choosenAnswerId])
          expect(aa.attempt_id).to eq(attempt.id)
        end
      end
    end

    context "when assessment doesn't exist" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]

        make_request(
          :post,
          "v1/questions/1/finish",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "assessment")).to eq(["is not exist"])
      end
    end

    context "when body is not an error" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]
        assessment = Factory[:assessment, :exam]

        make_request(
          :post,
          "v1/questions/#{assessment.id}/finish",
          auth_code: jwt_token,
          params: { questionId: 1, choosenAnswerId: 1 },
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "questions")).to eq(["should be an array"])
      end
    end

    context "when body is not correctly structured" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]
        assessment = Factory[:assessment, :exam]

        make_request(
          :post,
          "v1/questions/#{assessment.id}/finish",
          auth_code: jwt_token,
          params: [{ questionId: 1, choosenAnswerId: "hello" }],
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "questions"))
          .to eq(["should be correctly structured"])
      end
    end

    context "when incorrect relations" do
      context "when everything exist" do
        it "returns error" do
          jwt_token, uid = make_jwt_token
          Factory[:user, uid: uid]
          data = prepare_data
          body = data[:question_answers].map.with_index do |qa, i|
            answer =
              data.dig(:question_answers, i + 1, :answers, 0) ||
              data.dig(:question_answers, i - 1, :answers, 0)

            {
              questionId: qa[:question].id,
              choosenAnswerId: answer.id,
            }
          end

          make_request(
            :post,
            "v1/questions/#{data[:assessment].id}/finish",
            auth_code: jwt_token,
            params: body,
          )

          expect(last_response.status).to eq(422)
          expect(parsed_body.dig("errors", "questions"))
            .to eq(["incorrect relationships"])
        end
      end
    end

    context "when user not registered yet" do
      it "returns error" do
        jwt_token, = make_jwt_token
        assessment = Factory[:assessment, :exam]

        make_request(
          :post,
          "v1/questions/#{assessment.id}/finish",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end

  def prepare_data
    assessment = Factory[
      :assessment,
      :exam,
      questions_amount: 4,
    ]
    question_answers = []
    Array.new(4) do
      q = Factory[:question]
      Factory[
        :assessment_question,
        assessment: assessment,
        question: q,
      ]

      ans = Array.new(3) { Factory[:answer, question: q] }
      ans.push(Factory[:answer, :correct, question: q])

      question_answers.push(
        question: q,
        answers: ans,
      )
    end

    {
      assessment: assessment,
      question_answers: question_answers,
    }
  end

  def attempts_repo
    Medlibra::Container["repositories.attempts_repo"]
  end

  def attempt_answers_repo
    Medlibra::Container["repositories.attempt_answers_repo"]
  end
end
