# frozen_string_literal: true

require "web_spec_helper"
require "oj"

RSpec.xdescribe "v1/subjects", type: :request do
  describe "#GET" do
    it "returns exams by year" do
      uid = SecureRandom.hex
      kid = SecureRandom.hex
      jwt_token = jwt_token_by(uid: uid, kid: kid)
      krok1 = Factory[:krok]
      field1 = Factory[:field, krok_id: krok1.id]
      year1 = Factory[:year]
      krok2 = Factory[:krok]
      field2 = Factory[:field, krok_id: krok2.id]
      year2 = Factory[:year]
      Factory[
        :user,
        uid: uid,
        krok_id: krok1.id,
        field_id: field1.id,
      ]

      expected_subjects = Array.new(3) do
        subj = Factory[:subfield]
        Factory[
          :assessment,
          :training,
          krok_id: krok1.id,
          field_id: field1.id,
          subfield_id: subj.id,
          year_id: year1.id
        ]
        subj
      end
      expected_ids = expected_subjects.map(&:id)
      expected_names = expected_subjects.map(&:name)
      Factory[
        :assessment,
        :training,
        krok_id: krok2.id,
        field_id: field2.id,
        subfield_id: Factory[:subfield].id,
        year_id: year2.id
      ]

      header "Authorization", "Bearer #{jwt_token}"
      get "v1/subjects"

      expect(last_response).to be_successful
      parsed = JSON.parse(last_response.body)

      expect(parsed.map { |d| d["id"] }).to eq(expected_ids)
      expect(parsed.map { |d| d["name"] }).to eq(expected_names)
    end

    context "when user is not yet registered" do
      it "returns error" do
        uid = SecureRandom.hex
        kid = SecureRandom.hex
        jwt_token = jwt_token_by(uid: uid, kid: kid)
        krok1 = Factory[:krok]
        field1 = Factory[:field, krok_id: krok1.id]
        year1 = Factory[:year]
        krok2 = Factory[:krok]
        field2 = Factory[:field, krok_id: krok2.id]
        year2 = Factory[:year]
        Factory[
          :user,
          uid: uid,
          krok_id: krok1.id,
          field_id: field1.id,
        ]

        Array.new(3) do
          subj = Factory[:subfield]
          Factory[
            :assessment,
            :training,
            krok_id: krok1.id,
            field_id: field1.id,
            subfield_id: subj.id,
            year_id: year1.id
          ]
        end
        Factory[
          :assessment,
          :training,
          krok_id: krok2.id,
          field_id: field2.id,
          subfield_id: Factory[:subfield].id,
          year_id: year2.id
        ]

        header "Authorization", "Bearer #{jwt_token}"
        get "v1/subjects"

        expect(last_response.status).to eq(422)
        parsed = JSON.parse(last_response.body)

        expect(parsed["error"]).to eq("user doesn't exist")
      end
    end
  end
end
