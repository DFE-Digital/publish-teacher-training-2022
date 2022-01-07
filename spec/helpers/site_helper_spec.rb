# frozen_string_literal: true

require "rails_helper"

describe SiteHelper do
  include SiteHelper

  describe "#new_publish_link_for" do
    let(:path) { "/organisations/random" }
    let(:expected_path) { "#{Settings.new_publish_url}/publish/organisations/random" }

    it "returns a correct url linking back to the old publish" do
      expect(new_publish_link_for(path)).to eq(expected_path)
    end
  end
end
