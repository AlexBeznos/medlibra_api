# frozen_string_literal: true

require "db_spec_helper"

require "medlibra/services/questions/save_results"

RSpec.describe Medlibra::Services::Questions::SaveResults do
  describe "#call" do
    context "when success" do
      it "returns success monad" do
        data = prepare_data
        params = data[:params]

        result = described_class.new.(**params)

        expect(result).to be_success
      end

      it "saves data to db" do
        data = prepare_data
        params = data[:params]

        described_class.new.(**params)

        expect(attempts_repo.attempts.count).to eq(1)
        attempt = attempts_repo.attempts.one
        expect(attempt.score).to eq(1)
        expect(attempt.assessment_id).to eq(data[:assessment].id)
        expect(attempt.user_id).to eq(data[:user].id)

        expect(answers_repo.attempt_answers.count).to eq(4)
        data[:questions].each do |q|
          exist =
            answers_repo
            .attempt_answers
            .where(question_id: q[:question].id)
            .where(answer_id: q[:correct].id)
            .where(attempt_id: attempt.id)
            .exist?

          expect(exist).to eq(true)
        end
      end
    end

    context "one of the answers not exist" do
      it "returns failure monad" do
        data = prepare_data
        params = data[:params]
        params[:params].last[:choosen_answer_id] = 125

        result = described_class.new.(**params)

        expect(result).to be_failure
        expect(result.failure).to eq(questions: ["incorrect relationships"])
      end

      it "doesn't save any data" do
        data = prepare_data
        params = data[:params]
        params[:params].last[:choosen_answer_id] = 125

        described_class.new.(**params)

        expect(attempts_repo.attempts.count).to eq(0)
        expect(answers_repo.attempt_answers.count).to eq(0)
      end
    end
  end

  def prepare_data
    user = Factory[:user]
    assessment = Factory[
      :assessment,
      :exam,
      questions_amount: 4,
    ]
    questions = []
    Array.new(4) do
      q = Factory[:question]
      Factory[
        :assessment_question,
        assessment: assessment,
        question: q,
      ]

      ans = Array.new(3) { Factory[:answer, question: q] }
      ans.push(Factory[:answer, :correct, question: q])

      questions.push(
        question: q,
        answers: ans,
        correct: ans.last,
      )
    end

    {
      assessment: assessment,
      questions: questions,
      user: user,
      params: {
        score: 1.0,
        user: user,
        assessment_id: assessment.id,
        params: questions.map do |q|
          {
            question_id: q[:question].id,
            choosen_answer_id: q[:correct].id,
          }
        end,
      },
    }
  end

  def attempts_repo
    Medlibra::Container["repositories.attempts_repo"]
  end

  def answers_repo
    Medlibra::Container["repositories.attempt_answers_repo"]
  end
end
