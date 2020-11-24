require "rails_helper"

RSpec.describe HeartbeatController do
  describe "#sha" do
    around :each do |example|
      ENV["COMMIT_SHA"] = "some-sha"

      example.run
    end

    it "returns sha" do
      get :sha
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eql({ "sha" => "some-sha" })
    end
  end
end
