require "rails_helper"

RSpec.describe ProviderDecorator do
  let(:website) { "www.acmescitt.com" }

  let(:provider) do
    build(
      :provider,
      accredited_body?: false,
      website: website,
      address1: "1 Sample Road",
      postcode: "W1 ABC",
    )
  end

  subject { provider.decorate }

  describe "#website" do
    context "with website" do
      it { expect(subject.website).to eq("http://www.acmescitt.com") }
    end

    context "without website" do
      let(:website) { nil }

      it { expect(subject.website).to eq(nil) }
    end
  end
end
