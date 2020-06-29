require "rails_helper"

RSpec.describe HeartbeatController do
  describe "#sha" do
    around :each do |example|
      File.open("COMMIT_SHA", "w") { |f| f.write "some-sha" }

      example.run

      File.delete("COMMIT_SHA")
    end

    it "returns sha" do
      get :sha
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eql({ "sha" => "some-sha" })
    end
  end
end
