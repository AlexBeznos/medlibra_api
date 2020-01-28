require "jwt"
require "oj"

module Test
  module Utils
    def fixture_file(path)
      File.read(SPEC_ROOT.join("fixtures", path))
    end

    def prepare_jwt_token(header = {}, payload = {}, key = nil)
      key ||= OpenSSL::PKey::RSA.generate(1024)

      JWT.encode(
        payload,
        key,
        "RS256",
        header,
      )
    end

    def fixture_cert_key
      file = Oj.load(fixture_file("certs.json"))

      [
        OpenSSL::X509::Certificate.new(file["cert"]),
        OpenSSL::PKey::RSA.new(file["key"]),
      ]
    end
  end
end

