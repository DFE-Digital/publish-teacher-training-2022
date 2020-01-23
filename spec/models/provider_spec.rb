describe Provider do
  describe "#publish" do
    let(:provider) { build(:provider) }

    it "publishes" do
      publish_endpoint = stub_api_v2_request("/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}/publish", {}, :post)
      RequestStore.store[:manage_courses_backend_token] = ""
      provider.publish
      expect(publish_endpoint).to have_been_requested
    end
  end
end
