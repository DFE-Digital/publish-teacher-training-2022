require "rails_helper"

describe FeatureService do
  let(:feature_enabled) { true }

  around(:each) do |example|
    old_value = Settings.features.rspec_testing
    Settings.features.rspec_testing = feature_enabled
    example.run
    Settings.features.rspec_testing = old_value
  end

  describe ".require" do
    context "feature is enabled" do
      let(:feature_enabled) { true }

      it "returns true" do
        response = FeatureService.require(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      let(:feature_enabled) { false }

      it "raises an error" do
        expect { FeatureService.require(:rspec_testing) }
          .to raise_error(
            RuntimeError,
            "Feature rspec_testing is disabled",
          )
      end
    end
  end

  describe ".enabled?" do
    context "feature is enabled" do
      let(:feature_enabled) { true }

      it "returns true" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      let(:feature_enabled) { false }

      it "returns false" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_falsey
      end
    end
  end
end
