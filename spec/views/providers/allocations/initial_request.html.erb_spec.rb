require "rails_helper"

RSpec.describe "providers/allocations/initial_request.html.erb" do
  context "when there are associated training providers" do
    let(:provider) { build(:provider) }
    let(:training_providers) { [build(:provider)] }
    let(:form_object) { InitialRequestForm.new }

    it "shows radio buttons" do
      render template: "providers/allocations/initial_request.html.erb",
             locals: {
               provider: provider,
               form_object: form_object,
               training_providers: training_providers,
             }

      expect(rendered).to include("govuk-radios__item")
    end
  end

  context "when there are no associated training providers" do
    let(:provider) { build(:provider) }
    let(:training_providers) { [] }
    let(:form_object) { InitialRequestForm.new }

    it "does not show radio buttons" do
      render template: "providers/allocations/initial_request.html.erb",
             locals: {
               provider: provider,
               form_object: form_object,
               training_providers: training_providers,
             }

      expect(rendered).to_not include("govuk-radios__item")
    end
  end
end
