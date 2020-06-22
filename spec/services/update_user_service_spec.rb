require "rails_helper"

describe UpdateUserService do
  let(:user) do
    build(
      :user,
      :rolled_over,
      associated_with_accredited_body: true,
      notifications_configured: false,
    )
  end

  let(:user_update_request) do
    stub_request(
      :post,
      "#{Settings.manage_backend.base_url}/api/v2/users",
    )
      .with(body: /"state":"notifications_configured"/)
  end

  describe ".call" do
    context "a successful update request" do
      before do
        user_update_request
      end

      it "sends the request" do
        described_class.call(user, "accept_notifications_screen!")
        expect(user_update_request).to have_been_made
      end
    end

    context "Any error other than JsonAPIClient error" do
      let(:user_update_request) do
        stub_request(
          :post,
          "#{Settings.manage_backend.base_url}/api/v2/users",
        ).to_raise(StandardError)
      end

      before do
        user_update_request
      end

      it "error is raised" do
        expect { described_class.call(user, "accept_notifications_screen!") }.to raise_error(StandardError)
      end
    end
  end
end
