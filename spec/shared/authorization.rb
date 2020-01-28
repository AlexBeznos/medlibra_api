require "securerandom"
require "oj"

RSpec.shared_context "authorization" do
  let(:fetch_jwt_key_double) do
    instance_double(
      Medlibra::Container["services.fetch_jwt_key"].class,
    )
  end

  before do
    Medlibra::Container.stub(
      "services.fetch_jwt_key",
      fetch_jwt_key_double,
    )
  end
  
  after { Medlibra::Container.unstub("services.fetch_jwt_key") }

  def certs_fixture
    @certs_fixture ||= Oj.load(fixture_file("certs.json"))
  end

  def jwt_token_by(uid: SecureRandom.hex, kid: SecureRandom.hex)
    allow(fetch_jwt_key_double).
      to receive(:call).
      with(kid).
      and_return(certs_fixture["cert"])

    prepare_jwt_token(
      { "alg" => "RS256", "kid" => kid },
      { 
        "exp" => Time.now.to_i + 1300,
        "auth_time" => Time.now.to_i - 1300,
        "iat" => Time.now.to_i - 1300,
        "aud" => Medlibra::Container["validations.jwt.payload"].class::PROJECT_ID,
        "iss" => Medlibra::Container["validations.jwt.payload"].class::ISSUER,
        "sub" => uid,
      },
      OpenSSL::PKey::RSA.new(certs_fixture["key"]),
    )
  end
end
