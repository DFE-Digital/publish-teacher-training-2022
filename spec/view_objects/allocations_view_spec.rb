require "rails_helper"

describe AllocationsView do
  let(:training_provider) { build(:provider) }
  let(:another_training_provider) { build(:provider) }
  let(:accredited_body) { build(:provider) }
  let(:training_providers) { [training_provider, another_training_provider] }

  describe "#allocation_renewals" do
    subject { AllocationsView.new(training_providers: training_providers, allocations: allocations).repeat_allocation_statuses }

    context "Accrediting provider has re-requested an allocation for a training provider" do
      let(:repeat_allocation) do
        build(:allocation, :repeat, accredited_body: accredited_body, provider: training_provider, number_of_places: 1)
      end
      let(:initial_allocation) do
        build(:allocation, :initial, accredited_body: accredited_body, provider: another_training_provider, number_of_places: 3)
      end
      let(:allocations) { [repeat_allocation, initial_allocation] }

      it {
        is_expected.to eq([
          {
            training_provider_name: training_provider.provider_name,
            training_provider_code: training_provider.provider_code,
            status: AllocationsView::Status::REQUESTED,
            status_colour: AllocationsView::Colour::GREEN,
            requested: AllocationsView::Requested::YES,
            id: repeat_allocation.id,
          },
        ])
      }
    end

    context "Accredited body has declined an allocation for a training provider" do
      let(:declined_allocation) { build(:allocation, :declined, accredited_body: accredited_body, provider: training_provider, number_of_places: 0) }
      let(:initial_allocation) do
        build(:allocation, :initial, accredited_body: accredited_body, provider: another_training_provider, number_of_places: 3)
      end
      let(:allocations) { [declined_allocation, initial_allocation] }

      it {
        is_expected.to eq([
          {
            training_provider_name: training_provider.provider_name,
            training_provider_code: training_provider.provider_code,
            status: AllocationsView::Status::NOT_REQUESTED,
            status_colour: AllocationsView::Colour::RED,
            requested: AllocationsView::Requested::NO,
            id: declined_allocation.id,
          },
        ])
      }
    end

    context "Accredited body is yet to repeat or decline an allocation for a training provider" do
      let(:allocations) { [] }

      it {
        is_expected.to eq([
          {
            training_provider_name: training_provider.provider_name,
            training_provider_code: training_provider.provider_code,
            status: AllocationsView::Status::YET_TO_REQUEST,
            status_colour: AllocationsView::Colour::GREY,
          },
          {
            training_provider_name: another_training_provider.provider_name,
            training_provider_code: another_training_provider.provider_code,
            status: AllocationsView::Status::YET_TO_REQUEST,
            status_colour: AllocationsView::Colour::GREY,
          },
        ])
      }
    end
  end

  describe "#initial_allocations" do
    subject { AllocationsView.new(training_providers: training_providers, allocations: allocations).initial_allocation_statuses }

    context "Accredited body has requested an initial allocation for a training provider" do
      context "more than 1 place requested" do
        let(:initial_allocation) do
          build(:allocation, :initial, accredited_body: accredited_body, provider: training_provider, number_of_places: 3)
        end

        let(:repeat_allocation) do
          build(:allocation, :repeat, accredited_body: accredited_body, provider: another_training_provider, number_of_places: 4)
        end

        let(:allocations) { [initial_allocation, repeat_allocation] }

        it {
          is_expected.to eq([
            {
              training_provider_name: training_provider.provider_name,
              training_provider_code: training_provider.provider_code,
              status: "3 PLACES REQUESTED",
              status_colour: AllocationsView::Colour::GREEN,
              requested: AllocationsView::Requested::YES,
              id: initial_allocation.id,
            },
          ])
        }
      end

      context "1 place requested" do
        let(:initial_allocation) do
          build(:allocation, :initial, accredited_body: accredited_body, provider: training_provider, number_of_places: 1)
        end

        let(:allocations) { [initial_allocation] }

        it "correctly pluralizes the status" do
          expect(subject.first[:status]).to eq("1 PLACE REQUESTED")
        end
      end
    end

    context "Accredited body has not requested initial allocations for any training provider" do
      let(:repeat_allocation) do
        build(:allocation, :repeat, accredited_body: accredited_body, provider: training_provider, number_of_places: 4)
      end

      let(:allocations) { [repeat_allocation] }

      it { is_expected.to be_empty }
    end
  end
end
