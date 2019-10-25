module PageObjects
  module Page
    module Organisations
      class UcasContactsAlerts < PageObjects::Base
        set_url "/organisations/{provider_code}/ucas-contacts/alerts"

        element :main_heading, '[data-qa="ucas_contacts__alerts__main_heading"]'

        section :alerts_enabled_fields, '[data-qa="ucas_contacts__alerts_enabled"]' do
          element :all, '[data-qa="ucas_contacts__alerts_enabled__all"]'
          element :none, '[data-qa="ucas_contacts__alerts_enabled__none"]'
        end
        element :application_alert_contact, 'input[data-qa="ucas_contacts__application_alert_contact"]'
        element :share_with_ucas_permission, '[data-qa="ucas_contacts__share_with_ucas_permission"]'

        element :error_summary, ".govuk-error-summary"
      end
    end
  end
end
