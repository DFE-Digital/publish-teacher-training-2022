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
end
