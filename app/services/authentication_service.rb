module AuthenticationService
  class << self
    DFE_SIGNIN = "dfe_signin".freeze
    PERSONA = "persona".freeze
    MAGIC_LINK = "magic_link".freeze

    def basic_auth?
      persona? && !Settings.authentication.basic_auth.disabled
    end

    def mode
      case Settings.authentication.mode
      when MAGIC_LINK
        MAGIC_LINK
      when PERSONA
        PERSONA
      else
        DFE_SIGNIN
      end
    end

    def dfe_signin?
      mode == DFE_SIGNIN
    end

    def magic_link?
      mode == MAGIC_LINK
    end

    def persona?
      mode == PERSONA
    end
  end
end
