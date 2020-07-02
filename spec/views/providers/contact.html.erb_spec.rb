require "rails_helper"

RSpec.describe "providers/contact.html.erb" do
  before do
    assign(:provider, build(:provider))
  end

  context "when not an admin" do
    before do
      controller.singleton_class.class_eval do
      protected

        def current_user
          { "admin" => false }
        end
        helper_method :current_user
      end
    end

    it "cannot see provider_name field" do
      render

      expect(rendered).to_not include("Provider name")
    end
  end

  context "when an admin" do
    before do
      controller.singleton_class.class_eval do
      protected

        def current_user
          { "admin" => true }
        end
        helper_method :current_user
      end
    end

    it "can see provider_name field" do
      render

      expect(rendered).to include("Provider name")
    end
  end
end
