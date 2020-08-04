# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "v1/subjects", type: :request do
  describe "#GET" do
    it "returns all subjects by user's krok and field" do
      jwt_token, uid = make_jwt_token
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

      make_request(
        :get,
        "v1/subjects",
        auth_code: jwt_token,
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body.map { |d| d["id"] }).to eq(expected_ids)
      expect(parsed_body.map { |d| d["name"] }).to eq(expected_names)
    end

    context "when user is not yet registered" do
      it "returns error" do
        jwt_token, = make_jwt_token
        krok1 = Factory[:krok]
        field1 = Factory[:field, krok_id: krok1.id]
        year1 = Factory[:year]
        krok2 = Factory[:krok]
        field2 = Factory[:field, krok_id: krok2.id]
        year2 = Factory[:year]

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

        make_request(
          :get,
          "v1/subjects",
          auth_code: jwt_token,
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end
end
