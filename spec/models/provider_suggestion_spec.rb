require "rails_helper"

describe ProviderSuggestion do
  describe "#suggest" do
    let(:provider)          { build :provider }
    let(:recruitment_cycle) { provider.recruitment_cycle }
    let(:new_resource_stub) { stub_api_v2_new_resource(provider) }

    def stub_suggestion(query, stub)
      stub_api_v2_request(
        "/providers/suggest?query=#{query}",
        stub,
      )
    end

    before do
      allow(Thread.current).to receive(:fetch).and_return("token")

      stub_omniauth
      new_resource_stub
    end

    it "requests suggestions" do
      provider_suggestion1 = build(:provider_suggestion)
      provider_suggestion2 = build(:provider_suggestion)
      query_stub = stub_suggestion("query", resource_list_to_jsonapi([provider_suggestion1, provider_suggestion2]))
      ProviderSuggestion.suggest("query")
      expect(query_stub).to have_been_requested
    end


    it "returns the result" do
      provider_suggestion1 = build(:provider_suggestion)
      provider_suggestion2 = build(:provider_suggestion)
      stub_suggestion("query", resource_list_to_jsonapi([provider_suggestion1, provider_suggestion2]))
      result = ProviderSuggestion.suggest("query")

      expect(result.length).to eq(2)
      expect(result.first.attributes[:type]).to eq("provider")
      expect(result.first.attributes[:provider_code]).to eq(provider_suggestion1.provider_code)
      expect(result.first.attributes[:provider_name]).to eq(provider_suggestion1.provider_name)

      expect(result.second.attributes[:type]).to eq("provider")
      expect(result.second.attributes[:provider_code]).to eq(provider_suggestion2.provider_code)
      expect(result.second.attributes[:provider_name]).to eq(provider_suggestion2.provider_name)
    end
  end
end
