module PageObjects
  module Page
    class TransitionInfo < PageObjects::Base
      set_url '/transition-info'

      element :title, 'h1'
      element :continue, '[data-qa=transition__continue]'
    end
  end
end
