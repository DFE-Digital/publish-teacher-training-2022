require "rails_helper"

describe Provider do
  let(:provider) { build(:provider) }

  describe "#publish" do
    it "publishes" do
      publish_endpoint = stub_api_v2_request("/recruitment_cycles/#{provider.recruitment_cycle.year}/providers/#{provider.provider_code}/publish", {}, :post)
      RequestStore.store[:manage_courses_backend_token] = ""
      provider.publish
      expect(publish_endpoint).to have_been_requested
    end
  end

  describe "#from_previous_recruitment_cycle" do
    context "when the response from ttapi has some results" do
      let(:organisation_response) { <<~JSON }
         {
           "data":[
              {
                 "id":"7",
                 "type":"providers",
                 "attributes":{
                    "provider_code": "A06",
                    "provider_name": "ACME"
                 }
              }
           ],
           "meta":{
              "count":1
           },
           "jsonapi":{
              "version":"1.0"
           }
        }
      JSON

      it "find a provider with the same code but previous recruitment cycle" do
        cycle = Settings.current_cycle.pred
        stub = stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/recruitment_cycles/#{cycle}/providers/#{provider.provider_code}")
          .to_return(
            status: 200,
            body: organisation_response,
            headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" },
          )

        from_previous_cycle = provider.from_previous_recruitment_cycle
        expect(stub).to have_been_requested
        expect(from_previous_cycle).to be_a(Provider)
        expect(from_previous_cycle.provider_code).to eq "A06"
        expect(from_previous_cycle.provider_name).to eq "ACME"
      end
    end
  end

  describe "#from_next_recruitment_cycle" do
    let(:provider_response) { <<~JSON }
        {
          "data":[
            {
                "id":"",
                "type":"providers",
                "attributes":{
                  "provider_code": "#{provider.provider_code}",
                  "provider_name": "#{provider.provider_name}",
                  "recruitment_cycle_year": "#{next_cycle}"
                }
            }
          ],
          "meta":{
            "count":1
          },
          "jsonapi":{
            "version":"1.0"
          }
      }
    JSON

    let(:next_cycle) { Settings.current_cycle.succ }

    let(:stub) do
      stub_request(:get, "#{Settings.teacher_training_api.base_url}/api/v2/recruitment_cycles/#{next_cycle}/providers/#{provider.provider_code}")
      .to_return(
        status_body_headers,
      )
    end

    before do
      stub
    end

    context "when a provider has been rolled over into the next recruitment cycle" do
      let(:status_body_headers) { { status: 200, body: provider_response, headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" } } }

      it "detects that provider" do
        from_next_cycle = provider.from_next_recruitment_cycle
        expect(from_next_cycle.provider_code).to eql(provider.provider_code)
        expect(from_next_cycle.recruitment_cycle_year).to eql(next_cycle.to_s)
        expect(stub).to have_been_requested
      end
    end

    context "when a provider has not been rolled over into the next recruitment cycle" do
      let(:status_body_headers) { { status: 404, body: nil, headers: { "Content-Type": "application/vnd.api+json; charset=utf-8" } } }

      it "does not detect that provider" do
        from_next_cycle = provider.from_next_recruitment_cycle
        expect(from_next_cycle).to be_nil
        expect(stub).to have_been_requested
      end
    end
  end
end
