# frozen_string_literal: true

require "securerandom"
require "web_spec_helper"

RSpec.describe "POST v1/users", type: :request do
  context "when success" do
    it "returns status 200" do
      params = { username: "@hello" }
      jwt_token, = make_jwt_token

      make_request(
        :post,
        "v1/users",
        auth_code: jwt_token,
        params: params,
      )

      expect(last_response).to be_successful
    end

    it "creates users record" do
      users_repo = Medlibra::Container["repositories.users_repo"]
      params = { username: "@hello" }
      jwt_token, uid = make_jwt_token

      expect do
        make_request(
          :post,
          "v1/users",
          auth_code: jwt_token,
          params: params,
        )
      end.to change(users_repo.users, :count).from(0).to(1)
      expect(users_repo.users.one.to_h).to include(username: "@hello", uid: uid)
    end
  end

  context "when failure" do
    it "returns status 422" do
      params = { username: nil }
      jwt_token, = make_jwt_token

      make_request(
        :post,
        "v1/users",
        auth_code: jwt_token,
        params: params,
      )

      expect(last_response).to be_unprocessable
    end

    it "not creates records" do
      users_repo = Medlibra::Container["repositories.users_repo"]
      params = { username: nil }
      jwt_token, = make_jwt_token

      expect do
        make_request(
          :post,
          "v1/users",
          auth_code: jwt_token,
          params: params,
        )
      end.not_to change(users_repo.users, :count)
    end

    it "return errors" do
      params = { username: nil }
      jwt_token, = make_jwt_token

      make_request(
        :post,
        "v1/users",
        auth_code: jwt_token,
        params: params,
      )

      expect(parsed_body).to eq("errors" => { "username" => ["must be a string"] })
    end
  end

  context "when user not authenticated" do
    it "returns 401" do
      params = { username: "@hello" }

      make_request(
        :post,
        "v1/users",
        params: params,
      )

      expect(last_response).to be_unauthorized
    end
  end
end
