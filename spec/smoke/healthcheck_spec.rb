# frozen_string_literal: true

require "spec_helper_smoke"

describe "Publish Teacher Training Smoke Tests", :aggregate_failures, smoke: true do
  let(:base_url) { Settings.publish_url }

  subject(:response) { HTTParty.get(url) }

  describe "GET #{Settings.publish_url}/healthcheck" do
    let(:url) { "#{base_url}/healthcheck" }

    it "returns HTTP success" do
      expect(response.code).to eq(200)
    end

    it "returns JSON" do
      expect(response.content_type).to eq("application/json")
    end

    it "returns the expected response report" do
      expect(response.body).to eq(
        {
          checks: {
            teacher_training_api: true,
          },
        }.to_json,
      )
    end
  end

  describe "GET #{Settings.publish_url}/ping" do
    let(:url) { "#{base_url}/ping" }

    it "returns HTTP success" do
      expect(response.code).to eq(200)
    end

    it "returns HTML" do
      expect(response.content_type).to eq("text/html")
    end

    it "returns the expected response report" do
      expect(response.body).to eq("PONG")
    end
  end
end
