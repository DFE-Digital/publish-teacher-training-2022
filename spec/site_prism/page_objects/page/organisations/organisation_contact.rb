module PageObjects
  module Page
    module Organisations
      class OrganisationContact < PageObjects::Base
        set_url '/organisations/{provider_code}/contact'

        element :title, '.govuk-heading-xl'
        element :caption, '.govuk-caption-xl'
        element :email, '[data-qa=email]'
        element :telephone, '[data-qa=telephone]'
        element :website, '[data-qa=website]'
        element :address1, '[data-qa=address1]'
        element :address2, '[data-qa=address2]'
        element :address3, '[data-qa=address3]'
        element :address4, '[data-qa=address4]'
        element :postcode, '[data-qa=postcode]'
      end
    end
  end
end
