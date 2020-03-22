# frozen_string_literal: true

require "securerandom"
require "web_spec_helper"

RSpec.describe "POST v1/users", type: :request do
  context "when success" do
    it "returns status 200" do
      params = { username: "@hello" }
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"
      post "v1/users", params

      expect(last_response).to be_successful
    end

    it "creates users record" do
      users_repo = Medlibra::Container["repositories.users_repo"]
      params = { username: "@hello" }
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"

      expect do
        post "v1/users", params
      end.to change(users_repo.users, :count).from(0).to(1)
      expect(users_repo.users.one.to_h).to include(username: "@hello", uid: uid)
    end
  end

  context "when failure" do
    it "returns status 422" do
      params = { username: nil }
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"
      post "v1/users", params

      expect(last_response).to be_unprocessable
    end

    it "not creates records" do
      users_repo = Medlibra::Container["repositories.users_repo"]
      params = { username: nil }
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"

      expect do
        post "v1/users", params
      end.not_to change(users_repo.users, :count)
    end

    it "return errors" do
      params = { username: nil }
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)

      header "Authorization", "Bearer #{jwt_token}"
      post "v1/users", params

      expect(JSON.parse(last_response.body)).to eq("errors" => { "username" => ["must be a string"] })
    end
  end

  context "when user not authenticated" do
    it "returns 401" do
      params = { username: "@hello" }

      post "v1/users", params

      expect(last_response).to be_unauthorized
    end
  end
end
