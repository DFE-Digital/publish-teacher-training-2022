require "rails_helper"

RSpec.describe SendRequestEventsToBigquery do
  describe "#perform" do
    let(:request_event) do
      {
        environment: "production",
        request_method: "GET",
        request_path: "/mystery_path",
        request_uuid: "1c94ee0c-c217-4c45-a633-d649ff30a4c3",
        timestamp: Time.zone.now.iso8601,
        user_id: 3456,
      }
    end

    let(:project) { instance_double(Google::Cloud::Bigquery::Project, dataset: dataset) }
    let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset, table: table) }
    let(:table) { instance_double(Google::Cloud::Bigquery::Table) }

    before do
      allow(Google::Cloud::Bigquery).to receive(:new).and_return(project)
      allow(table).to receive(:insert)
      allow(Settings.google.bigquery).to receive(:project_id).and_return("publish-test")
      allow(Settings.google.bigquery).to receive(:dataset).and_return("publish-test-events")
    end

    it "sends request event JSON to Bigquery" do
      described_class.perform_now(request_event.as_json)

      expect(table).to have_received(:insert).with([request_event.as_json])
    end
  end
end
