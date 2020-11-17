require "rails_helper"

describe JWT::EncodeService do
  let(:email) { "bat@localhost" }
  let(:payload) { { "email" => email } }
  let(:now) { 1_605_093_071 }

  let(:expected_token_values) do
    {
      "data" => payload,
      **claims,
    }
  end

  let(:claims) do
    {
      "aud" => Settings.teacher_training_api.audience,
      "exp" => (now + 6.hours).to_i,
      "iat" => now.to_i,
      "iss" => Settings.teacher_training_api.issuer,
      "sub" => Settings.teacher_training_api.subject,
    }
  end

  let(:decoded_token) do
    JWT.decode(
      subject,
      Settings.teacher_training_api.secret,
      false, # NOTE: do not verify, it is the client responsibilities
    ).first
  end

  let(:static_decoded_token) do
    token = "eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImVtYWlsIjoiYmF0QGxvY2FsaG9zdCJ9LCJhdWQiOiJ0ZWFjaGVyLXRyYWluaW5nLWFwaSIsImV4cCI6MTYwNTExNDY3MSwiaWF0IjoxNjA1MDkzMDcxLCJpc3MiOiJwdWJsaXNoLXRlYWNoZXItdHJhaW5pbmciLCJzdWIiOiJhY2Nlc3MifQ.wjqihS2hKNR5l3k9fInL_0n6mwv45B5pZxyaBUvvYtQ"
    JWT.decode(
      token,
      Settings.teacher_training_api.secret,
      false, # NOTE: do not verify, it is the client responsibilities
    ).first
  end

  subject do
    described_class.call(payload: payload)
  end

  describe "#call" do
    before :each do
      allow(Time).to receive(:zone)
        .and_return(OpenStruct.new(now: now))
    end

    it "token values are equal" do
      expect(decoded_token).to match(expected_token_values)
      expect(static_decoded_token).to match(expected_token_values)
    end
  end
end
