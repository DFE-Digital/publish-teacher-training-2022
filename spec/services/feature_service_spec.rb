require "rails_helper"

describe FeatureService do
  let(:feature_value) { true }

  around(:each) do |example|
    old_value = Settings.features.rspec_testing
    Settings.features.rspec_testing = feature_value
    example.run
    Settings.features.rspec_testing = old_value
  end

  describe ".require" do
    context "feature is enabled" do
      let(:feature_value) { true }

      it "returns true" do
        response = FeatureService.require(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      let(:feature_value) { false }

      it "raises an error" do
        expect { FeatureService.require(:rspec_testing) }
          .to raise_error(RuntimeError, "Feature rspec_testing is disabled")
      end
    end

    context "nested feature is enabled" do
      let(:feature_value) { Config::Options.new nested: true }

      it "returns true" do
        response = FeatureService.require("rspec_testing.nested")

        expect(response).to be_truthy
      end
    end

    context "nested feature is disabled" do
      let(:feature_value) { Config::Options.new nested: false }

      it "raises an error" do
        expect { FeatureService.require("rspec_testing.nested") }
          .to raise_error(RuntimeError, "Feature rspec_testing.nested is disabled")
      end
    end
  end

  describe ".enabled?" do
    context "feature is enabled" do
      let(:feature_value) { true }

      it "returns true" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      let(:feature_value) { false }

      it "returns false" do
        response = FeatureService.enabled?(:rspec_testing)

        expect(response).to be_falsey
      end
    end

    context "nested feature is enabled" do
      let(:feature_value) { Config::Options.new nested: true }

      it "looks up the feature using dot-separated segments" do
        response = FeatureService.enabled?("rspec_testing.nested")

        expect(response).to be_truthy
      end
    end

    context "nested feature is disabled" do
      let(:feature_value) { Config::Options.new nested: false }

      it "looks up the feature using dot-separated segments" do
        response = FeatureService.enabled?("rspec_testing.nested")

        expect(response).to be_falsey
      end
    end
  end
end
