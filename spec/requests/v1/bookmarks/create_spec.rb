# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "POST v1/bookmarks", type: :request do
  context "when success" do
    it "creates bookmark and returns 201 status" do
      jwt_token, uid = make_jwt_token
      krok1 = Factory[:krok]
      field1 = Factory[:field, krok_id: krok1.id]
      user = Factory[
        :user,
        uid: uid,
        krok_id: krok1.id,
        field_id: field1.id,
      ]
      question = Factory[:question]

      make_request(
        :post,
        "v1/bookmarks",
        auth_code: jwt_token,
        params: { questionId: question.id },
      )

      expect(last_response.status).to eq(201)
      bookmark = find_last_bookmark

      expect(bookmark.question_id).to eq(question.id)
      expect(bookmark.user_id).to eq(user.id)
    end
  end

  context "when question is not exist" do
    it "returns error" do
      jwt_token, uid = make_jwt_token
      krok1 = Factory[:krok]
      field1 = Factory[:field, krok_id: krok1.id]
      Factory[
        :user,
        uid: uid,
        krok_id: krok1.id,
        field_id: field1.id,
      ]

      make_request(
        :post,
        "v1/bookmarks",
        auth_code: jwt_token,
        params: { questionId: 1 },
      )

      expect(last_response.status).to eq(422)
      expect(parsed_body.dig("errors", "question_id")).to eq(["is not exist"])
    end
  end

  context "when questionId is not provided" do
    it "returns error" do
      jwt_token, uid = make_jwt_token
      krok1 = Factory[:krok]
      field1 = Factory[:field, krok_id: krok1.id]
      Factory[
        :user,
        uid: uid,
        krok_id: krok1.id,
        field_id: field1.id,
      ]

      make_request(
        :post,
        "v1/bookmarks",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(422)
      expect(parsed_body.dig("errors", "question_id")).to eq(["is missing"])
    end
  end

  context "when user is not created" do
    it "returns error" do
      jwt_token, = make_jwt_token
      question = Factory[:question]

      make_request(
        :post,
        "v1/bookmarks",
        auth_code: jwt_token,
        params: { questionId: question.id },
      )

      expect(last_response.status).to eq(422)
      expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
    end
  end

  def find_last_bookmark
    Medlibra::Container["repositories.bookmarks_repo"]
      .bookmarks
      .order { created_at.desc }
      .first
  end
end
