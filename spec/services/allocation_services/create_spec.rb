require "rails_helper"

module AllocationServices
  describe Create do
    describe ".call" do
      let(:provider_id) { 1 }
      let(:accredited_body_code) { "ABC" }
      let(:number_of_places) { 10 }

      context "requested: true" do
        context "number_of_places provided" do
          it "creates an initial request" do
            expect(Allocation).to receive(:create)
              .with(
                provider_code: accredited_body_code,
                provider_id: provider_id,
                number_of_places: number_of_places,
                request_type: Allocation::RequestTypes::INITIAL,
              )

            described_class.call(
              accredited_body_code: accredited_body_code,
              provider_id: provider_id,
              number_of_places: number_of_places,
              request_type: Allocation::RequestTypes::INITIAL,
            )
          end
        end

        context "number_of_places not provided" do
          it "creates a repeat request" do
            expect(Allocation).to receive(:create)
              .with(
                provider_code: accredited_body_code,
                provider_id: provider_id,
                request_type: Allocation::RequestTypes::REPEAT,
              )

            described_class.call(
              accredited_body_code: accredited_body_code,
              provider_id: provider_id,
              request_type: Allocation::RequestTypes::REPEAT,
            )
          end
        end
      end

      context "requested: false" do
        it "creates a declined request" do
          expect(Allocation).to receive(:create)
            .with(
              provider_code: accredited_body_code,
              provider_id: provider_id,
              request_type: Allocation::RequestTypes::DECLINED,
            )

          described_class.call(
            accredited_body_code: accredited_body_code,
            provider_id: provider_id,
            request_type: Allocation::RequestTypes::DECLINED,
          )
        end
      end
    end
  end
end
