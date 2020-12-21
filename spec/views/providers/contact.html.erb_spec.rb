require "rails_helper"

RSpec.describe "providers/contact.html.erb" do
  module CurrentUserMethod
    def current_user; end
  end

  before do
    view.extend(CurrentUserMethod)
    assign(:provider, build(:provider))
    allow(view).to receive(:current_user).and_return({ "admin" => admin })
  end

  context "when not an admin" do
    let(:admin) { false }

    it "cannot see provider_name field" do
      render

      expect(rendered).to_not include("Provider name")
    end
  end

  context "when an admin" do
    let(:admin) { true }

    it "can see provider_name field" do
      render

      expect(rendered).to include("Provider name")
    end
  end
end
