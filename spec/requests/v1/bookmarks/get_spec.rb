# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "GET v1/bookmarks", type: :request do
  it "returns bookmarks list" do
    jwt_token, uid = make_jwt_token
    krok1 = Factory[:krok]
    field1 = Factory[:field, krok_id: krok1.id]
    year1 = Factory[:year]
    year2 = Factory[:year]
    user = Factory[
      :user,
      uid: uid,
      krok_id: krok1.id,
      field_id: field1.id,
    ]
    question1 = Factory[:question]
    correct_answer1 = Factory[:answer, question_id: question1.id, correct: true]
    Array.new(3) do
      Factory[
        :answer,
        question_id: question1.id,
        correct: false,
      ]
    end
    assessment1 = Factory[
      :assessment,
      :exam,
      krok: krok1,
      field: field1,
      year: year1,
    ]
    Factory[
      :assessment_question,
      assessment: assessment1,
      question: question1,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question1,
    ]
    question2 = Factory[:question]
    correct_answer2 = Factory[:answer, question_id: question2.id, correct: true]
    Array.new(3) do
      Factory[
        :answer,
        question_id: question2.id,
        correct: false,
      ]
    end
    subfield = Factory[:subfield]
    assessment2 = Factory[
      :assessment,
      :training,
      krok: krok1,
      field: field1,
      year: year1,
      subfield: subfield,
    ]
    Factory[
      :assessment_question,
      assessment: assessment2,
      question: question2,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question2,
    ]
    question3 = Factory[:question]
    correct_answer3 = Factory[:answer, question_id: question3.id, correct: true]
    Array.new(3) do
      Factory[
        :answer,
        question_id: question3.id,
        correct: false,
      ]
    end
    assessment3 = Factory[
      :assessment,
      :exam,
      krok: krok1,
      field: field1,
      year: year2,
    ]
    Factory[
      :assessment_question,
      assessment: assessment3,
      question: question3,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question3,
    ]

    make_request(
      :get,
      "v1/bookmarks",
      auth_code: jwt_token,
    )

    expect(last_response.status).to eq(200)

    expect(parsed_body["hasNext"]).to eq(false)
    expect(parsed_body["hasPrev"]).to eq(false)

    questions = parsed_body["questions"]

    expect(questions.count).to eq(3)
    questions.each do |q|
      expect(q.keys).to match_array(%w[id title year subfield type answer])
    end

    expect(questions[0]["id"]).to eq(question3.id)
    expect(questions[0]["title"]).to eq(question3.title)
    expect(questions[0]["year"]).to eq(year2.name)
    expect(questions[0]["subfield"]).to be_nil
    expect(questions[0]["type"]).to eq("exam")
    expect(questions[0]["answer"]).to eq(correct_answer3.title)

    expect(questions[1]["id"]).to eq(question2.id)
    expect(questions[1]["title"]).to eq(question2.title)
    expect(questions[1]["year"]).to eq(year1.name)
    expect(questions[1]["subfield"]).to eq(subfield.name)
    expect(questions[1]["type"]).to eq("training")
    expect(questions[1]["answer"]).to eq(correct_answer2.title)

    expect(questions[2]["id"]).to eq(question1.id)
    expect(questions[2]["title"]).to eq(question1.title)
    expect(questions[2]["year"]).to eq(year1.name)
    expect(questions[2]["subfield"]).to be_nil
    expect(questions[2]["type"]).to eq("exam")
    expect(questions[2]["answer"]).to eq(correct_answer1.title)
  end

  it "include only user related bookmarks" do
    jwt_token, uid = make_jwt_token
    krok = Factory[:krok]
    field = Factory[:field, krok_id: krok.id]
    year = Factory[:year]
    user1 = Factory[
      :user,
      uid: "fake uid",
      krok_id: krok.id,
      field_id: field.id,
    ]
    Factory[
      :user,
      uid: uid,
      krok_id: krok.id,
      field_id: field.id,
    ]
    question = Factory[:question]
    assessment = Factory[
      :assessment,
      :exam,
      krok: krok,
      field: field,
      year: year,
    ]
    Factory[
      :assessment_question,
      assessment: assessment,
      question: question,
    ]
    Factory[
      :bookmark,
      user: user1,
      question: question,
    ]

    make_request(
      :get,
      "v1/bookmarks",
      auth_code: jwt_token,
      params: { limit: 2, offset: 0 },
    )

    expect(last_response.status).to eq(200)

    expect(parsed_body["hasNext"]).to eq(false)
    expect(parsed_body["hasPrev"]).to eq(false)
    expect(parsed_body["questions"]).to eq([])
  end

  it "paginatable" do
    jwt_token, uid = make_jwt_token
    krok1 = Factory[:krok]
    field1 = Factory[:field, krok_id: krok1.id]
    year1 = Factory[:year]
    year2 = Factory[:year]
    user = Factory[
      :user,
      uid: uid,
      krok_id: krok1.id,
      field_id: field1.id,
    ]
    question1 = Factory[:question]
    Factory[:answer, question_id: question1.id, correct: true]
    assessment1 = Factory[
      :assessment,
      :exam,
      krok: krok1,
      field: field1,
      year: year1,
    ]
    Factory[
      :assessment_question,
      assessment: assessment1,
      question: question1,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question1,
    ]
    question2 = Factory[:question]
    Factory[:answer, question_id: question2.id, correct: true]
    subfield = Factory[:subfield]
    assessment2 = Factory[
      :assessment,
      :training,
      krok: krok1,
      field: field1,
      year: year1,
      subfield: subfield,
    ]
    Factory[
      :assessment_question,
      assessment: assessment2,
      question: question2,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question2,
    ]
    question3 = Factory[:question]
    Factory[:answer, question_id: question3.id, correct: true]
    assessment3 = Factory[
      :assessment,
      :exam,
      krok: krok1,
      field: field1,
      year: year2,
    ]
    Factory[
      :assessment_question,
      assessment: assessment3,
      question: question3,
    ]
    Factory[
      :bookmark,
      user: user,
      question: question3,
    ]

    make_request(
      :get,
      "v1/bookmarks",
      auth_code: jwt_token,
      params: { limit: 2, offset: 0 },
    )

    expect(last_response.status).to eq(200)

    expect(parsed_body["hasNext"]).to eq(true)
    expect(parsed_body["hasPrev"]).to eq(false)

    questions = parsed_body["questions"]
    expect(questions.count).to eq(2)
    expect(questions.map { |q| q["id"] })
      .to eq([question3.id, question2.id])

    make_request(
      :get,
      "v1/bookmarks",
      auth_code: jwt_token,
      params: { limit: 2, offset: 2 },
    )

    expect(last_response.status).to eq(200)

    reload_parsed_body!

    expect(parsed_body["hasNext"]).to eq(false)
    expect(parsed_body["hasPrev"]).to eq(true)

    questions = parsed_body["questions"]
    expect(questions.count).to eq(1)
    expect(questions.map { |q| q["id"] })
      .to eq([question1.id])
  end

  context "when user is not created yet" do
    it "returns returns error" do
      jwt_token, = make_jwt_token

      make_request(
        :get,
        "v1/bookmarks",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(422)
      expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
    end
  end
end
