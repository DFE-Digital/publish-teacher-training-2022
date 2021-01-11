module AuthenticationService
  class << self
    DFE_SIGNIN = "dfe_signin".freeze
    PERSONA = "persona".freeze
    MAGIC = "magic".freeze

    def basic_auth?
      persona? && !Settings.authentication.basic_auth.disabled
    end

    def mode
      case Settings.authentication.mode
      when MAGIC
        MAGIC
      when PERSONA
        PERSONA
      else
        DFE_SIGNIN
      end
    end

    def dfe_signin?
      mode == DFE_SIGNIN
    end

    def magic?
      mode == MAGIC
    end

    def persona?
      mode == PERSONA
    end
  end
end
