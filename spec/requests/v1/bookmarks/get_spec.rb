# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "GET v1/bookmarks", type: :request do
  it "returns bookmarks list" do
    uid = SecureRandom.hex
    kid = SecureRandom.hex
    jwt_token = jwt_token_by(uid: uid, kid: kid)
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

    header "Authorization", "Bearer #{jwt_token}"
    get "v1/bookmarks"

    expect(last_response.status).to eq(200)
    parsed = JSON.parse(last_response.body)

    expect(parsed["hasNext"]).to eq(false)
    expect(parsed["hasPrev"]).to eq(false)

    questions = parsed["questions"]

    expect(questions.count).to eq(3)
    questions.each do |q|
      expect(q.keys).to match_array(%w[id title year subfield type])
    end

    expect(questions[0]["id"]).to eq(question3.id)
    expect(questions[0]["title"]).to eq(question3.title)
    expect(questions[0]["year"]).to eq(year2.name)
    expect(questions[0]["subfield"]).to be_nil
    expect(questions[0]["type"]).to eq("exam")

    expect(questions[1]["id"]).to eq(question2.id)
    expect(questions[1]["title"]).to eq(question2.title)
    expect(questions[1]["year"]).to eq(year1.name)
    expect(questions[1]["subfield"]).to eq(subfield.name)
    expect(questions[1]["type"]).to eq("training")

    expect(questions[2]["id"]).to eq(question1.id)
    expect(questions[2]["title"]).to eq(question1.title)
    expect(questions[2]["year"]).to eq(year1.name)
    expect(questions[2]["subfield"]).to be_nil
    expect(questions[2]["type"]).to eq("exam")
  end

  it "include only user related bookmarks" do
    uid = SecureRandom.hex
    kid = SecureRandom.hex
    jwt_token = jwt_token_by(uid: uid, kid: kid)
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

    header "Authorization", "Bearer #{jwt_token}"
    get "v1/bookmarks", params: { limit: 2, offset: 0 }

    expect(last_response.status).to eq(200)
    parsed = JSON.parse(last_response.body)

    expect(parsed["hasNext"]).to eq(false)
    expect(parsed["hasPrev"]).to eq(false)
    expect(parsed["questions"]).to eq([])
  end

  it "paginatable" do
    uid = SecureRandom.hex
    kid = SecureRandom.hex
    jwt_token = jwt_token_by(uid: uid, kid: kid)
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

    header "Authorization", "Bearer #{jwt_token}"
    get "v1/bookmarks", limit: 2, offset: 0

    expect(last_response.status).to eq(200)
    parsed = JSON.parse(last_response.body)

    expect(parsed["hasNext"]).to eq(true)
    expect(parsed["hasPrev"]).to eq(false)

    questions = parsed["questions"]
    expect(questions.count).to eq(2)
    expect(questions.map { |q| q["id"] })
      .to eq([question3.id, question2.id])

    header "Authorization", "Bearer #{jwt_token}"
    get "v1/bookmarks", limit: 2, offset: 2

    expect(last_response.status).to eq(200)
    parsed = JSON.parse(last_response.body)

    expect(parsed["hasNext"]).to eq(false)
    expect(parsed["hasPrev"]).to eq(true)

    questions = parsed["questions"]
    expect(questions.count).to eq(1)
    expect(questions.map { |q| q["id"] })
      .to eq([question1.id])
  end

  context "when user is not created yet" do
    it "returns returns error" do
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"
      get "v1/bookmarks"

      expect(last_response.status).to eq(422)
      parsed = JSON.parse(last_response.body)

      expect(parsed["errors"]).to eq(["user doesn't exist"])
    end
  end
end
