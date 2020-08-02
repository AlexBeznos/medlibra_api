# frozen_string_literal: true

require "web_spec_helper"

RSpec.describe "v1/assessments/:assessment_id/chunks", type: :request do
  describe "#POST" do
    it "returns chunk ids" do
      jwt_token, uid = make_jwt_token
      user = Factory[:user, uid: uid]
      assessment = Factory[:assessment, :exam]
      questions = Array.new(10) do
        Factory[:question].tap do |question|
          Factory[
            :assessment_question,
            question_id: question.id,
            assessment_id: assessment.id,
          ]
        end
      end

      make_request(
        :post,
        "v1/assessments/#{assessment.id}/chunks",
        auth_code: jwt_token,
        params: {
          chunkSize: 2,
        },
      )

      expect(last_response.status).to eq(200)
      expect(parsed_body.keys).to eq(["questionChunkIds"])
      chunk_ids = parsed_body["questionChunkIds"]

      questions.each_slice(2).with_index do |slice, index|
        chunk = assessment_chunks_repo
                .assessment_chunks
                .combine(:questions)
                .where(id: chunk_ids[index])
                .one

        expect(chunk.user_id).to eq(user.id)
        expect(chunk.assessment_id).to eq(assessment.id)
        expect(chunk.questions.map(&:id)).to eq(slice.map(&:id))
      end
    end

    context "when chunk size is not valid" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]
        assessment = Factory[:assessment, :exam]

        make_request(
          :post,
          "v1/assessments/#{assessment.id}/chunks",
          auth_code: jwt_token,
          params: {
            chunkSize: "fake",
          },
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "chunk_size")).to eq(["must be an integer"])
      end

      context "when chunk is too big" do
        it "returns error" do
          jwt_token, uid = make_jwt_token
          Factory[:user, uid: uid]
          assessment = Factory[:assessment, :exam]

          make_request(
            :post,
            "v1/assessments/#{assessment.id}/chunks",
            auth_code: jwt_token,
            params: {
              chunkSize: 32,
            },
          )

          expect(last_response.status).to eq(422)
          expect(parsed_body.dig("errors", "chunk_size")).to eq(["must be less than or equal to 30"])
        end
      end
    end

    context "when assessment is not exist" do
      it "returns error" do
        jwt_token, uid = make_jwt_token
        Factory[:user, uid: uid]

        make_request(
          :post,
          "v1/assessments/23/chunks",
          auth_code: jwt_token,
          params: {
            chunkSize: 10,
          },
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "assessment")).to eq(["is not exist"])
      end
    end

    context "when user not exist" do
      it "returns error" do
        jwt_token, = make_jwt_token
        assessment = Factory[:assessment, :exam]

        make_request(
          :post,
          "v1/assessments/#{assessment.id}/chunks",
          auth_code: jwt_token,
          params: {
            chunkSize: 10,
          },
        )

        expect(last_response.status).to eq(422)
        expect(parsed_body.dig("errors", "user")).to eq(["is not exist"])
      end
    end
  end

  def assessment_chunks_repo
    Medlibra::Container["repositories.assessment_chunks_repo"]
  end
end
