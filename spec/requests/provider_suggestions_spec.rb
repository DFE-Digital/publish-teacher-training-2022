require "rails_helper"

describe "/providers/suggest", type: :request do
  let(:provider) { build(:provider) }

  before do
    stub_omniauth(provider: provider)
    get(auth_dfe_callback_path)
  end

  context "when provider suggestion is blank" do
    it "returns bad request (400)" do
      get "/providers/suggest"

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq("error" => "Bad request")
    end
  end

  context "when provider suggestion is less than three characters" do
    it "returns bad request (400)" do
      get "/providers/suggest?query=St"

      expect(response.status).to eq(400)
      expect(JSON.parse(response.body)).to eq("error" => "Bad request")
    end
  end

  context "when the request raises an JsonApiClient::Errors::ClientError" do
    let(:query) { "(Reach Academy Feltham" }

    before do
      stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/providers/suggest?query=#{query}").and_raise(JsonApiClient::Errors::ClientError)
      get "/providers/suggest?query=#{query}"
    end

    it "returns an empty result set" do
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  context "when provider suggestion query is valid" do
    query = "Girls School"
    query_with_unicode_character = "Girls%E2%80%99 School"

    [query, query_with_unicode_character].each do |provider_query|
      it "returns success (200) for query: '#{provider_query}'" do
        provider_suggestions = stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/providers/suggest?query=#{provider_query}")
                                 .to_return(
                                   headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
                                   body: File.new("spec/fixtures/api_responses/provider-suggestions.json"),
                                 )

        get "/providers/suggest?query=#{provider_query}"

        expect(provider_suggestions).to have_been_requested
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(
          [
            {
              "code" => "A0",
              "name" => "ACME SCITT 0",
            },
            {
              "code" => "A01",
              "name" => "Acme SCITT",
            },
            {
              "code" => "B01",
              "name" => "Bar SCITT",
            },
          ],
        )
      end
    end
  end
end
