require "rails_helper"

describe "providers/show" do
  let(:provider_show_page) { PageObjects::Page::Organisations::OrganisationShow.new }
  let(:provider_view) { instance_double(ProviderView) }

  module CurrentUserMethod
    def current_user; end
  end

  before do
    view.extend(CurrentUserMethod)
    allow(view).to receive(:current_user).and_return({ "admin" => admin })
    assign(:provider, provider)
    allow(provider_view).to receive(:show_notifications_link?).and_return(notifications_link_boolean)
    assign(:provider_view, provider_view)
    render

    provider_show_page.load(rendered)
  end

  context "provider is an accredited body" do
    let(:provider) { build(:provider, :accredited_body) }
    let(:notifications_link_boolean) { true }

    context "user is an admin" do
      let(:admin) { true }

      it "displays the PE allocation link" do
        expect(provider_show_page).to have_request_allocations_link
      end
    end

    context "user isn't an admin" do
      let(:admin) { false }

      it "displays the PE allocation link" do
        expect(provider_show_page).to have_request_allocations_link
      end

      it "displays the 'Courses as an accredited body' link" do
        expect(provider_show_page).to have_courses_as_accredited_body_link
      end

      it "displays the notification preferences" do
        expect(provider_show_page).to have_notifications_preference_link
      end
    end

    context "more than one provider is an accredited body" do
      let(:admin) { false }
      let(:provider) { build(:provider, :accredited_body) }
      let(:notifications_link_boolean) { false }

      it "doesn't display the notification preferences" do
        expect(provider_show_page).not_to have_notifications_preference_link
      end
    end
  end

  context "provider is not an accredited body" do
    let(:provider) { build(:provider) }
    let(:notifications_link_boolean) { false }

    context "user is an admin" do
      let(:admin) { true }

      it "doesn't display the PE allocationlink" do
        expect(provider_show_page).not_to have_request_allocations_link
      end

      it "doesn't display the 'Courses as an accredited body' link" do
        expect(provider_show_page).not_to have_courses_as_accredited_body_link
      end

      it "doesn't display the notification preferences" do
        expect(provider_show_page).not_to have_notifications_preference_link
      end
    end

    context "user is not an admin" do
      let(:admin) { false }

      it "doesn't display the PE allocationlink" do
        expect(provider_show_page).not_to have_request_allocations_link
      end

      it "doesn't display the 'Courses as an accredited body' link" do
        expect(provider_show_page).not_to have_courses_as_accredited_body_link
      end

      it "doesn't display the notification preferences" do
        expect(provider_show_page).not_to have_notifications_preference_link
      end
    end
  end
end
