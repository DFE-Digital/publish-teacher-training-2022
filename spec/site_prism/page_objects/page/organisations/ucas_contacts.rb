module PageObjects
  module Page
    module Organisations
      class UcasContacts < PageObjects::Base
        set_url "/organisations/{provider_code}/ucas-contacts"

        element :flash, ".govuk-success-summary"
        element :utt_contact, '[data-qa="provider__utt_contact"]'
        element :web_link_contact, '[data-qa="provider__web_link_contact"]'
        element :finance_contact, '[data-qa="provider__finance_contact"]'
        element :fraud_contact, '[data-qa="provider__fraud_contact"]'
        element :admin_contact, '[data-qa="provider__admin_contact"]'
        element :gt12_contact, '[data-qa="provider__gt12_contact"]'
        element :application_alert_contact, '[data-qa="provider__application_alert_contact"]'
        element :send_application_alerts, '[data-qa="provider__send_application_alerts"]'
        element :send_application_alerts_link, "a[data-qa=send_application_alerts__change]", text: "Change"
      end
    end
  end
end
