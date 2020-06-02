require "rails_helper"

describe "providers/index" do
  let(:provider_index_page) { PageObjects::Page::RootPage.new }
  let(:pagy) { instance_double(Pagy) }
  let(:providers_view) { instance_double(ProvidersView) }
  let(:provider) { build(:provider, :accredited_body) }
  let(:provider2) { build(:provider, :accredited_body) }

  module CurrentUserMethod
    def current_user; end
  end

  before do
    view.extend(CurrentUserMethod)
    allow(pagy).to receive(:prev)
    allow(pagy).to receive(:next)
    assign(:pagy, pagy)

    assign(:providers, providers)
    allow(provider).to receive(:course_count).and_return(1)
    allow(provider2).to receive(:course_count).and_return(1)

    allow(providers_view).to receive(:show_notifications_link?).and_return(notifications_link_boolean)
    assign(:providers_view, providers_view)

    render

    provider_index_page.load(rendered)
  end

  context "one provider is an accredited body" do
    let(:providers) { [provider] }
    let(:notifications_link_boolean) { false }

    it "doesn't display the notification preferences" do
      expect(provider_index_page).not_to have_notifications_preference_link
    end
  end

  context "more than one provider is an accredited body" do
    let(:providers) do
      [provider, provider2]
    end
    let(:notifications_link_boolean) { true }

    it "displays the notification preferences" do
      expect(provider_index_page).to have_notifications_preference_link
    end
  end
end
