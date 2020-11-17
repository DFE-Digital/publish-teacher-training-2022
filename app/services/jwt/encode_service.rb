module JWT
  class EncodeService
    include ServicePattern

    def initialize(payload:)
      @payload = payload
    end

    def call
      JWT.encode(
        data,
        Settings.teacher_training_api.secret,
        Settings.teacher_training_api.algorithm,
      )
    end

  private

    attr_reader :payload

    def data
      {
        data: payload,
        **claims,
      }
    end

    def claims
      now = Time.zone.now
      {
        aud: Settings.teacher_training_api.audience,
        exp: (now + 6.hours).to_i,
        iat: now.to_i,
        iss: Settings.teacher_training_api.issuer,
        sub: Settings.teacher_training_api.subject,
      }
    end
  end
end
