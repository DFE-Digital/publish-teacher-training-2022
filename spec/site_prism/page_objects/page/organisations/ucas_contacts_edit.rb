module PageObjects
  module Page
    module Organisations
      class UcasContactsEdit < PageObjects::Base
        set_url "/organisations/{provider_code}/ucas-contacts"

        element :name_field, "#contact-name-field"
        element :email_field, "#contact-email-field"
        element :telephone_field, "#contact-telephone-field"
        element :submit_button, "#contact_edit_form .govuk-button"
        element :error_message, ".govuk-error-summary"
        element :admin_subtext, "#admin_subtext"
        element :admin_subheading, "#contact_edit_form h2"
      end
    end
  end
end
