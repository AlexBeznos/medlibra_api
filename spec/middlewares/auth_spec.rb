# frozen_string_literal: true

require "spec_helper"
require "medlibra/middlewares/auth"
require "medlibra/services/decode_jwt"

RSpec.describe Medlibra::Middlewares::Auth do
  context "when header not provided" do
    it "return status 401" do
      status, = described_class.new.call({})

      expect(status).to eq(401)
    end
  end

  context "when header have incorrect type" do
    it "return status 401" do
      env = {
        "HTTP_AUTHORIZATION" => "Basic somefakedata"
      }

      status, = described_class.new.call(env)

      expect(status).to eq(401)
    end
  end

  context "when jwt token decode failed" do
    it "return status 401" do
      env = {
        "HTTP_AUTHORIZATION" => "Bearer expiredtoken"
      }
      decoder_instance = instance_double(Medlibra::Services::DecodeJwt)
      Medlibra::Container.stub(
        "services.decode_jwt",
        decoder_instance,
      )
      allow(decoder_instance)
        .to receive(:call)
        .with("expiredtoken")
        .and_return(false)

      status, = described_class.new.call(env)

      expect(status).to eq(401)

      Medlibra::Container.unstub("services.decode_jwt")
    end
  end

  context "when jwt decoded successfully" do
    it "call app with updated env" do
      app = instance_double("Roda app")
      env = {
        "HTTP_AUTHORIZATION" => "Bearer token"
      }
      decoder_instance = instance_double(Medlibra::Services::DecodeJwt)
      expected_env = env.merge("firebase.uid" => "123123")

      Medlibra::Container.stub(
        "services.decode_jwt",
        decoder_instance,
      )

      allow(decoder_instance)
        .to receive(:call)
        .with("token")
        .and_return("sub" => "123123")

      allow(app).to receive(:call).with(expected_env)

      described_class
        .new(app)
        .call(env)

      expect(app).to have_received(:call).with(expected_env)

      Medlibra::Container.unstub("services.decode_jwt")
    end
  end
end
