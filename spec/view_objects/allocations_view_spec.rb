require "rails_helper"

describe AllocationsView do
  describe "#allocations" do
    describe "status calculation" do
      let(:training_provider) { build(:provider) }
      let(:accredited_body) { build(:provider) }
      let(:training_providers) { [training_provider] }
      let(:allocations) { [allocation] }

      subject { AllocationsView.new(training_providers: training_providers, allocations: allocations).allocation_statuses }

      context "Accrediting provider has requested an allocation for a training provider" do
        let(:allocation) {
          build(:allocation, accredited_body: accredited_body, provider: training_provider, number_of_places: 1)
        }

        it {
          is_expected.to eq([
            {
              training_provider_name: training_provider.provider_name,
              training_provider_code: training_provider.provider_code,
              status: AllocationsView::Status::REQUESTED,
              status_colour: AllocationsView::Colour::GREEN,
              requested: AllocationsView::Requested::YES,
            },
          ])
        }
      end

      context "Accrediting provider has not requested an allocation for a training provider" do
        let(:allocation) { build(:allocation, accredited_body: accredited_body, provider: training_provider, number_of_places: 0) }

        it {
          is_expected.to eq([
            {
              training_provider_name: training_provider.provider_name,
              training_provider_code: training_provider.provider_code,
              status: AllocationsView::Status::NOT_REQUESTED,
              status_colour: AllocationsView::Colour::RED,
              requested: AllocationsView::Requested::NO,
            },
          ])
        }
      end

      context "Accrediting provider is yet to request an allocation for a training provider" do
        let(:another_training_provider) { build(:provider) }
        let(:allocation) { build(:allocation, accredited_body: accredited_body, provider: another_training_provider, number_of_places: 2) }

        it {
          is_expected.to eq([
            {
              training_provider_name: training_provider.provider_name,
              training_provider_code: training_provider.provider_code,
              status: AllocationsView::Status::YET_TO_REQUEST,
              status_colour: AllocationsView::Colour::GREY,
            },
          ])
        }
      end
    end
  end
end
