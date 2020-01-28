require "spec_helper"
require "medlibra/services/fetch_jwt_key"
require "concurrent-ruby"

RSpec.describe Medlibra::Services::FetchJwtKey do
  context "when keys empty" do
    it "fetch from endpoint and return by key" do
      keys_stub = Concurrent::Map.new
      Medlibra::Container.stub("utils.jwt_keys", keys_stub)
      stub_call_for_keys({ key_1: "cert_1" }.to_json)
     
      result = Medlibra::Container["services.fetch_jwt_key"].("key_1")

      expect(result).to eq("cert_1")
      
      Medlibra::Container.unstub("utils.jwt_keys")
   end 
  end

  context "when prev keys expired" do
    it "fetch new keys" do
      keys_stub = Concurrent::Map.new
      keys_stub.put("exp_at", Time.now.to_i - 1200)
      keys_stub.put("key_1", "cert_1")
      keys_stub.put("key_2", "cert_2")

      Medlibra::Container.stub("utils.jwt_keys", keys_stub)
      stub_call_for_keys({ key_2: "cert_3" }.to_json)
     
      result = Medlibra::Container["services.fetch_jwt_key"].("key_2")

      expect(result).to eq("cert_3")
      expect(keys_stub["key_1"]).to eq(nil)
      
      Medlibra::Container.unstub("utils.jwt_keys")
    end
  end

  context "when keys pre cached" do
    it "returns cert from cache" do
      keys_stub = instance_double(Concurrent::Map)
      key = "key_1"

      Medlibra::Container.stub("utils.jwt_keys", keys_stub)
      allow(keys_stub).to receive(:empty?).and_return(false)
      allow(keys_stub).to receive(:[]).with("exp_at").and_return(Time.now.to_i + 1200)
      allow(keys_stub).to receive(:[]).with(key).and_return("cert_1")
      
      result = Medlibra::Container["services.fetch_jwt_key"].(key)

      expect(result).to eq("cert_1")
      
      Medlibra::Container.unstub("utils.jwt_keys")
    end
  end

  def stub_call_for_keys(body, headers: {}, cache: 24250, with_cache: true)
    headers ||= {}
    headers.merge!(
      "cache-control" => "public, max-age=#{cache}, must-revalidate, no-transform",
    ) if with_cache

    stub_request(:get, described_class::KEY_URL).
      to_return(
        body: body,
        headers: headers,
      )
  end

  def prepare_headers_for_stub(headers)
    header_arr = ["HTTP/2 200"]
    headers.map { |*kv| header_arr.push(kv.join(": ")) }
    header_arr.join("\r\n")
  end
end
