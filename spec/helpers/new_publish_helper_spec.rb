# frozen_string_literal: true

require "rails_helper"

describe NewPublishHelper do
  include NewPublishHelper

  describe "#new_publish_url" do
    let(:path) { "/organisations/random" }
    let(:expected_path) { "#{Settings.new_publish.base_url}/organisations/random" }

    it "returns a correct url linking back to the old publish" do
      expect(new_publish_url(path)).to eq(expected_path)
    end
  end
end
