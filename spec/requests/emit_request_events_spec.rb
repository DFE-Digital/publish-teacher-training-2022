require "rails_helper"
require "sidekiq/testing"

RSpec.describe EmitRequestEvents, type: :request, feature_send_request_data_to_bigquery: true do
  let(:user) { create(:user) }
  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:project) { instance_double(Google::Cloud::Bigquery::Project, dataset: dataset) }
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset, table: table) }
  let(:table) { instance_double(Google::Cloud::Bigquery::Table) }

  before do
    stub_omniauth(user: user)
    get(auth_dfe_callback_path)
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(project)
    allow(table).to receive(:insert)

    Rails.application.routes.draw do
      get "/test", to: "test#test"
    end
  end

  class TestController < ::ApplicationController
    skip_before_action :check_interrupt_redirects

    def test
      render plain: "TEESSSSST"
    end
  end

  it "enqueues request event data with job to send to bigquery" do
    Timecop.freeze do
      now = Time.zone.now

      expect {
        get "/test"
      }.to(have_enqueued_job(SendRequestEventsToBigquery).with do |args|
        args = args.with_indifferent_access
        expect(args[:request_path]).to eq("/test")
        expect(args[:request_method]).to eq("GET")
        expect(args[:environment]).to eq("test")
        expect(args[:timestamp]).to eq(now.iso8601)
        expect(args[:user_id]).to eq(user.id)
      end)
    end
  end
end
