require "web_spec_helper"

RSpec.describe "v1/users", type: :request do
  describe "#POST" do
    context "when success" do
      it "returns status 200" do
        params = { username: "@hello" }

        post "v1/users", params

        expect(last_response).to be_successful
      end
      
      it "creates users record" do
        users_repo = Medlibra::Container["repositories.users_repo"]
        params = { username: "@hello" }

        expect {
          post "v1/users", params
        }.to change(users_repo.users, :count).from(0).to(1)
      end
    end

    context "when failure" do
      it "returns status 422" do
        params = { username: nil }

        post "v1/users", params

        expect(last_response).to be_unprocessable
      end

      it "not creates records" do
        users_repo = Medlibra::Container["repositories.users_repo"]
        params = { username: nil }

        expect {
          post "v1/users", params
        }.not_to change(users_repo.users, :count)
      end

      it "return errors" do
        params = { username: nil }

        post "v1/users", params
        
        expect(JSON.parse(last_response.body)).to eq({"errors" => { "username" => ["must be a string"] }})
      end
    end
  end
end
