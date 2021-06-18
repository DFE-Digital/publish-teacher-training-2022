require "rails_helper"

RSpec.describe Providers::AllocationsController, type: :controller do
  let(:current_recruitment_cycle) { build(:recruitment_cycle) }
  let(:accredited_body) { build(:provider, accredited_body?: is_accredited_body, recruitment_cycle: current_recruitment_cycle) }
  let(:is_accredited_body) { true }
  let(:user) { build(:user) }
  let(:allocations_state) { "open" }
  let(:current_user) do
    {
      user_id: 1,
      uid: SecureRandom.uuid,
      info: {
        email: "dave@example.com",
      },
      admin: user.admin,
      attributes: user.attributes,
    }.with_indifferent_access
  end

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    stub_api_v2_resource(current_recruitment_cycle)
    stub_api_v2_resource(accredited_body)
    allow(Settings.features.allocations).to receive(:state).and_return(allocations_state)
    stub_api_v2_request(
      "/providers/#{accredited_body.provider_code}/allocations?filter[recruitment_cycle][year][0]=#{previous_recruitment_cycle.year}&filter[recruitment_cycle][year][1]=#{current_recruitment_cycle.year}&include=provider,accredited_body",
      resource_list_to_jsonapi([*previous_allocations, *current_allocations].compact, include: "provider,accredited_body"),
    )
  end
  render_views

  describe "get #index" do
    before do
      get :index, params: {
        on: :member,
        provider_code: accredited_body.provider_code,
        recruitment_cycle_year: accredited_body.recruitment_cycle.year,
      }
    end

    shared_examples "allocation journey mode" do |journey_mode|
      let(:previous_recruitment_cycle) { build(:recruitment_cycle, :previous_cycle) }
      let(:previous_provider) { build(:provider, provider_code: provider.provider_code, accredited_body?: is_accredited_body, recruitment_cycle: previous_recruitment_cycle) }

      let(:training_provider_and_allocations_request_types_matrix) do
        [
          [build(:provider, provider_code: "PI1", recruitment_cycle: previous_recruitment_cycle), :initial],
          [build(:provider, provider_code: "PR1", recruitment_cycle: previous_recruitment_cycle), :repeat],
          [build(:provider, provider_code: "PD1", recruitment_cycle: previous_recruitment_cycle), :declined],
          [build(:provider, provider_code: "BI1", recruitment_cycle: previous_recruitment_cycle), :initial],
          [build(:provider, provider_code: "BR1", recruitment_cycle: previous_recruitment_cycle), :repeat],
          [build(:provider, provider_code: "BD1", recruitment_cycle: previous_recruitment_cycle), :declined],
          [build(:provider, provider_code: "CI1", recruitment_cycle: current_recruitment_cycle), :initial],
          [build(:provider, provider_code: "CR1", recruitment_cycle: current_recruitment_cycle), :repeat],
          [build(:provider, provider_code: "CD1", recruitment_cycle: current_recruitment_cycle), :declined],
          [build(:provider, provider_code: "BI1", recruitment_cycle: current_recruitment_cycle), :initial],
          [build(:provider, provider_code: "BR1", recruitment_cycle: current_recruitment_cycle), :repeat],
          [build(:provider, provider_code: "BD1", recruitment_cycle: current_recruitment_cycle), :declined],
        ]
      end
      let(:previous_training_providers) do
        training_provider_and_allocations_request_types_matrix.filter_map do |provider, _request_type|
          provider if provider.recruitment_cycle == previous_recruitment_cycle
        end
      end

      let(:current_training_providers) do
        training_provider_and_allocations_request_types_matrix.filter_map do |provider, _request_type|
          provider if provider.recruitment_cycle == current_recruitment_cycle
        end
      end

      let(:previous_allocations) do
        training_provider_and_allocations_request_types_matrix.filter_map do |provider, request_type|
          build(:allocation, request_type, accredited_body: accredited_body, provider: provider) if provider.recruitment_cycle == previous_recruitment_cycle
        end
      end

      let(:current_allocations) do
        training_provider_and_allocations_request_types_matrix.filter_map do |provider, request_type|
          build(:allocation, request_type, accredited_body: accredited_body, provider: provider) if provider.recruitment_cycle == current_recruitment_cycle
        end
      end

      let(:expected_training_providers) do
        previous_training_providers.filter_map { |provider|
          provider if %w[PI1
                         PR1
                         BI1
                         BR1].include?(provider.provider_code)
        }.sort_by(&:provider_name)
      end

      context "when allocation state is #{journey_mode}" do
        let(:allocations_state) { journey_mode }

        it "response is successfully" do
          expect(response).to be_successful
        end

        it "rendered the correct partials" do
          expect(response).to render_template(partial: "providers/allocations/_allocation_request_#{journey_mode}_state")
        end

        it "has expected_training_provider" do
          expect(controller.view_assigns["training_providers"].map(&:provider_name)).to contain_exactly(*expected_training_providers.map(&:provider_name))
        end
      end
    end

    include_examples "allocation journey mode", "closed"
    include_examples "allocation journey mode", "open"
    include_examples "allocation journey mode", "confirmed"

    context "non accredited body" do
      let(:is_accredited_body) { false }
      it "is not found" do
        expect(response).to be_not_found
        expect(response.body).to render_template("errors/not_found")
      end
    end
  end
end
