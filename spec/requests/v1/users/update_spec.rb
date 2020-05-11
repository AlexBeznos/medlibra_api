# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "PUT v1/users", type: :request do
  describe "#PUT" do
    context "when success" do
      context "when all attributes provided" do
        it "updates user" do
          jwt_token, uid = make_jwt_token
          user = Factory[:user, uid: uid]
          krok = Factory[:krok]
          field = Factory[:field, krok_id: krok.id]
          prev_created_at = user.created_at
          prev_updated_at = user.updated_at
          params = {
            krokId: krok.id,
            fieldId: field.id,
            helperNotificationsEnabled: true,
            changesNotificationsEnabled: true,
            learningIntensity: "hard",
          }

          make_request(
            :put,
            "v1/users",
            auth_code: jwt_token,
            params: params,
          )

          expect(last_response.status).to eq(204)
          expect(last_response.body).to be_empty
          next_user = find_user(user.id)

          expect(next_user.created_at).to eq(prev_created_at)
          expect(next_user.updated_at).not_to eq(prev_updated_at)
          expect(next_user.krok.id).to eq(krok.id)
          expect(next_user.field.id).to eq(field.id)
          expect(next_user.helper_notifications_enabled).to eq(true)
          expect(next_user.changes_notifications_enabled).to eq(true)
          expect(next_user.learning_intensity).to eq("hard")
        end
      end

      context "when only not relational attributes provided" do
        it "updates user" do
          jwt_token, uid = make_jwt_token
          user = Factory[:user, uid: uid]
          params = {
            helperNotificationsEnabled: true,
            changesNotificationsEnabled: true,
            learningIntensity: "hard",
          }

          make_request(
            :put,
            "v1/users",
            auth_code: jwt_token,
            params: params,
          )

          expect(last_response.status).to eq(204)
          next_user = find_user(user.id)

          expect(next_user.created_at).to eq(user.created_at)
          expect(next_user.updated_at).not_to eq(user.updated_at)
          expect(next_user.helper_notifications_enabled).to eq(true)
          expect(next_user.changes_notifications_enabled).to eq(true)
          expect(next_user.learning_intensity).to eq("hard")
        end
      end
    end

    context "when failure" do
      context "when only field provided" do
        it "return error that field not exist" do
          jwt_token, uid = make_jwt_token
          user = Factory[:user, uid: uid, krok_id: nil, field_id: nil]
          field = Factory[:field]
          params = { fieldId: field.id }

          make_request(
            :put,
            "v1/users",
            auth_code: jwt_token,
            params: params,
          )

          expect(last_response.status).to eq(422)
          expect(parsed_body.dig("errors", "field_id"))
            .to eq(["krok_id is required"])

          next_user = find_user(user.id)
          expect(next_user.krok).to be_nil
          expect(next_user.field).to be_nil
        end
      end

      context "when field not suited to krok" do
        it "returns proper error" do
          jwt_token, uid = make_jwt_token
          user = Factory[:user, uid: uid, krok_id: nil, field_id: nil]
          krok = Factory[:krok]
          field = Factory[:field]
          params = {
            krokId: krok.id,
            fieldId: field.id,
          }

          make_request(
            :put,
            "v1/users",
            auth_code: jwt_token,
            params: params,
          )

          expect(last_response.status).to eq(422)
          expect(parsed_body.dig("errors", "field_id"))
            .to eq(["not exist"])

          next_user = find_user(user.id)
          expect(next_user.krok).to be_nil
          expect(next_user.field).to be_nil
        end
      end
    end
  end

  def find_user(user_id)
    Medlibra::Container["repositories.users_repo"]
      .users
      .by_pk(user_id)
      .combine(:krok, :field)
      .one
  end
end
