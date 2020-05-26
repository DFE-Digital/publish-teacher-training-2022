require "rails_helper"

describe "notifications/index" do
  let(:notifications_index_page) { PageObjects::Page::Notifications::IndexPage.new }
  let(:notifications_view) { instance_double(NotificationsView) }
  let(:cancel_link_path) { "/organisations/B20" }

  before do
    allow(notifications_view).to receive(:user_id).and_return("123")
    allow(notifications_view).to receive(:user_email)
    allow(notifications_view).to receive(:user_notification_preferences).and_return(build(:user_notification_preferences))
    allow(notifications_view).to receive(:provider_code)
    allow(notifications_view).to receive(:cancel_link_path).and_return(cancel_link_path)
    assign(:notifications_view, notifications_view)

    render
    notifications_index_page.load(rendered)
  end

  describe "cancel changes link" do
    it "links to cancel link path" do
      expect(notifications_index_page.cancel_changes_link["href"]).to eq(cancel_link_path)
    end
  end
end
