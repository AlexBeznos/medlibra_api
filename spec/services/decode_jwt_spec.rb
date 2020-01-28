require "spec_helper"
require "medlibra/services/decode_jwt"
require "medlibra/services/fetch_jwt_key"
require "medlibra/validations/jwt/header"
require "medlibra/validations/jwt/payload"

RSpec.describe Medlibra::Services::DecodeJwt do
  context "when fake token" do
    it "return false" do
      result = Medlibra::Container["services.decode_jwt"].("fake")

      expect(result).to eq(false)
    end
  end

  context "when header not valid" do
    it "return nil" do
      header = { "alg" => "RS256", "kid" => "" }
      payload = { "sub" => "fake" }
      token = prepare_jwt_token(header, payload)
      validation_result = instance_double("Validation Result")

      header_validator = instance_double(Medlibra::Validations::Jwt::Header)
      payload_validator = instance_double(Medlibra::Validations::Jwt::Payload)
      Medlibra::Container.stub("validations.jwt.header", header_validator)
      Medlibra::Container.stub("validations.jwt.payload", payload_validator)

      allow(header_validator).
        to receive(:call).
        with(header).
        and_return(validation_result)
      allow(validation_result).to receive(:success?).and_return(false)
      allow(payload_validator).
        to receive(:call).
        with(payload)

      result = Medlibra::Container["services.decode_jwt"].(token)

      expect(result).to be_nil
      expect(payload_validator).not_to have_received(:call)

      Medlibra::Container.unstub("validations.jwt.header")
      Medlibra::Container.unstub("validations.jwt.payload")
    end
  end

  context "when payload not valid" do
    it "return nil" do
      header = { "alg" => "RS256", "kid" => "asdsad" }
      payload = { "sub" => "fake" }
      token = prepare_jwt_token(header, payload)
      header_validation_result = instance_double("Validation Result")
      payload_validation_result = instance_double("Validation Result")

      header_validator = instance_double(Medlibra::Validations::Jwt::Header)
      payload_validator = instance_double(Medlibra::Validations::Jwt::Payload)
      fetch_jwt_key = instance_double(Medlibra::Services::FetchJwtKey)
      Medlibra::Container.stub("validations.jwt.header", header_validator)
      Medlibra::Container.stub("validations.jwt.payload", payload_validator)
      Medlibra::Container.stub("services.fetch_jwt_key", fetch_jwt_key)

      allow(header_validator).
        to receive(:call).
        with(header).
        and_return(header_validation_result)
      allow(header_validation_result).
        to receive(:success?).and_return(true)
      allow(payload_validator).
        to receive(:call).
        with(payload).
        and_return(payload_validation_result)
      allow(payload_validation_result).
        to receive(:success?).and_return(false)
      allow(fetch_jwt_key).
        to receive(:call).
        with("asdasd")

      result = Medlibra::Container["services.decode_jwt"].(token)

      expect(result).to be_nil
      expect(fetch_jwt_key).not_to have_received(:call)

      Medlibra::Container.unstub("validations.jwt.header")
      Medlibra::Container.unstub("validations.jwt.payload")
      Medlibra::Container.unstub("services.fetch_jwt_key")
    end
  end

  context "when needed certificate not found" do
    it "return nil" do
      header = { "alg" => "RS256", "kid" => "asdasd" }
      payload = { "sub" => "id2323" }
      token = prepare_jwt_token(header, payload)
      header_validation_result = instance_double("Validation Result")
      payload_validation_result = instance_double("Validation Result")

      header_validator = instance_double(Medlibra::Validations::Jwt::Header)
      payload_validator = instance_double(Medlibra::Validations::Jwt::Payload)
      fetch_jwt_key = instance_double(Medlibra::Services::FetchJwtKey)
      Medlibra::Container.stub("validations.jwt.header", header_validator)
      Medlibra::Container.stub("validations.jwt.payload", payload_validator)
      Medlibra::Container.stub("services.fetch_jwt_key", fetch_jwt_key)

      allow(header_validator).
        to receive(:call).
        with(header).
        and_return(header_validation_result)
      allow(header_validation_result).
        to receive(:success?).and_return(true)
      allow(payload_validator).
        to receive(:call).
        with(payload).
        and_return(payload_validation_result)
      allow(payload_validation_result).
        to receive(:success?).and_return(true)
      allow(fetch_jwt_key).
        to receive(:call).
        with("asdasd").
        and_return(nil)

      result = Medlibra::Container["services.decode_jwt"].(token)

      expect(result).to be_nil
      expect(fetch_jwt_key).to have_received(:call)

      Medlibra::Container.unstub("validations.jwt.header")
      Medlibra::Container.unstub("validations.jwt.payload")
      Medlibra::Container.unstub("services.fetch_jwt_key")
    end
  end

  context "when certificate is not suited" do
    it "return false" do
      certs = JSON.parse(fixture_file("google_certs.json"))
      header = { "alg" => "RS256", "kid" => certs.first.first }
      payload = { "sub" => "id2323" }
      token = prepare_jwt_token(header, payload)
      header_validation_result = instance_double("Validation Result")
      payload_validation_result = instance_double("Validation Result")

      header_validator = instance_double(Medlibra::Validations::Jwt::Header)
      payload_validator = instance_double(Medlibra::Validations::Jwt::Payload)
      fetch_jwt_key = instance_double(Medlibra::Services::FetchJwtKey)
      Medlibra::Container.stub("validations.jwt.header", header_validator)
      Medlibra::Container.stub("validations.jwt.payload", payload_validator)
      Medlibra::Container.stub("services.fetch_jwt_key", fetch_jwt_key)

      allow(header_validator).
        to receive(:call).
        with(header).
        and_return(header_validation_result)
      allow(header_validation_result).
        to receive(:success?).and_return(true)
      allow(payload_validator).
        to receive(:call).
        with(payload).
        and_return(payload_validation_result)
      allow(payload_validation_result).
        to receive(:success?).and_return(true)
      allow(fetch_jwt_key).
        to receive(:call).
        with(certs.first.first).
        and_return(certs.to_a.last.last)

      result = Medlibra::Container["services.decode_jwt"].(token)

      expect(result).to be false

      Medlibra::Container.unstub("validations.jwt.header")
      Medlibra::Container.unstub("validations.jwt.payload")
      Medlibra::Container.unstub("services.fetch_jwt_key")
    end
  end

  context "when success" do
    it "return result of decode" do
      cert, key = fixture_cert_key

      header = { "alg" => "RS256", "kid" => "asdasd" }
      payload = { "sub" => "id2323" }
      token = prepare_jwt_token(header, payload, key)
      header_validation_result = instance_double("Validation Result")
      payload_validation_result = instance_double("Validation Result")

      header_validator = instance_double(Medlibra::Validations::Jwt::Header)
      payload_validator = instance_double(Medlibra::Validations::Jwt::Payload)
      fetch_jwt_key = instance_double(Medlibra::Services::FetchJwtKey)
      Medlibra::Container.stub("validations.jwt.header", header_validator)
      Medlibra::Container.stub("validations.jwt.payload", payload_validator)
      Medlibra::Container.stub("services.fetch_jwt_key", fetch_jwt_key)

      allow(header_validator).
        to receive(:call).
        with(header).
        and_return(header_validation_result)
      allow(header_validation_result).
        to receive(:success?).and_return(true)
      allow(payload_validator).
        to receive(:call).
        with(payload).
        and_return(payload_validation_result)
      allow(payload_validation_result).
        to receive(:success?).and_return(true)
      allow(fetch_jwt_key).
        to receive(:call).
        with("asdasd").
        and_return(cert.to_pem)

      rpayload, rheader = Medlibra::Container["services.decode_jwt"].(token)

      expect(rpayload).to eq(payload)
      expect(rheader).to eq(header)

      Medlibra::Container.unstub("validations.jwt.header")
      Medlibra::Container.unstub("validations.jwt.payload")
      Medlibra::Container.unstub("services.fetch_jwt_key")
    end
  end
end
