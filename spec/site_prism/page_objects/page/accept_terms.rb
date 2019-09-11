module PageObjects
  module Page
    class AcceptTerms < PageObjects::Base
      set_url '/accept-terms'

      element :title, 'h1'
      element :continue, '[data-qa=terms__continue]'
    end
  end
end
