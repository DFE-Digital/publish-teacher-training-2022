require "rails_helper"

describe MagicLink::GenerateAndSendService do
  let(:email) { "bat@localhost" }
  let(:site)  { "http://localhost:3000" }

  describe "#call" do
    let(:response) { spy("Response", success?: true) }

    before :each do
      allow(Faraday).to receive(:patch).and_return(response)
    end

    it "makes a PATCH request to the API" do
      described_class.call(email: email, site: site)

      expect(Faraday).to(
        have_received(:patch).with(
          "#{site}users/generate_and_send_magic_link",
          anything,
          anything,
        ),
      )
    end

    it "sends no params" do
      described_class.call(email: email, site: site)

      expect(Faraday).to(
        have_received(:patch).with(
          anything,
          {},
          anything,
        ),
      )
    end

    it "sets the Authorization header" do
      expected_token = JWT.encode(
        { email: email },
        Settings.teacher_training_api.secret,
        Settings.teacher_training_api.algorithm,
      )

      described_class.call(email: email, site: site)

      expect(Faraday).to(
        have_received(:patch).with(
          anything,
          anything,
          { "Authorization" => "Bearer #{expected_token}",
            "X-Request-Id" => anything },
        ),
      )
    end

    it "sets the X-Request-Id header" do
      request_id = spy("RequestId")
      allow(RequestStore).to(
        receive(:store).and_return(
          { request_id: request_id },
        ),
      )

      described_class.call(email: email, site: site)

      expect(Faraday).to(
        have_received(:patch).with(
          anything,
          anything,
          { "Authorization" => anything,
            "X-Request-Id" => request_id },
        ),
      )
    end

    context "response is not successful" do
      let(:response) do
        spy(
          "Response",
          success?: false,
          status: 500,
          reason_phrase: "API go BOOM",
        )
      end

      it "raises an error" do
        expect {
          described_class.call(email: email, site: site)
        }.to raise_error(RuntimeError, "500 received: API go BOOM")
      end
    end
  end
end
