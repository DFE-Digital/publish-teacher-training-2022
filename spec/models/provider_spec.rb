describe Provider do
  describe "#publish" do
    let(:provider) { build(:provider) }

    it "publishes" do
      publish_endpoint = stub_api_v2_request("/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}/publish", {}, :post)
      Thread.current[:manage_courses_backend_token] = ""
      provider.publish
      expect(publish_endpoint).to have_been_requested
    end
  end

  describe "#has_unpublished_changes?" do
    context "is published with unpublished changes" do
      let(:provider) { build(:provider, content_status: "published_with_unpublished_changes") }

      it "returns true" do
        expect(provider.has_unpublished_changes?).to eq(true)
      end
    end

    context "is published" do
      let(:provider) { build(:provider, content_status: "published") }

      it "return false" do
        expect(provider.has_unpublished_changes?).to eq(false)
      end
    end
  end

  describe "#is_published?" do
    context "is published with unpublished changes" do
      let(:provider) { build(:provider, content_status: "published_with_unpublished_changes") }

      it "returns true" do
        expect(provider.is_published?).to eq(false)
      end
    end

    context "is published" do
      let(:provider) { build(:provider, content_status: "published") }

      it "return false" do
        expect(provider.is_published?).to eq(true)
      end
    end
  end
end
