module PageObjects
  module Page
    module Organisations
      class UcasContacts < PageObjects::Base
        class SummaryList < SitePrism::Section
          element :value, ".govuk-summary-list__value"
          element :change_link, ".govuk-summary-list__actions .govuk-link"
        end

        set_url "/organisations/{provider_code}/ucas-contacts"

        element :flash, ".govuk-notification-banner--success"
        sections :contacts, SummaryList, "[data-qa~=ucas_contact]"
        section :admin_contact, SummaryList, "[data-qa~=ucas_admin_contact]"
        section :utt_contact, SummaryList, "[data-qa~=ucas_utt_contact]"
        section :web_link_contact, SummaryList, "[data-qa~=ucas_web_link_contact]"
        section :finance_contact, SummaryList, "[data-qa~=ucas_finance_contact]"
        section :fraud_contact, SummaryList, "[data-qa~=ucas_fraud_contact]"
        section :gt12_contact, SummaryList, "[data-qa=ucas_gt12_contact]"
        section :application_alert_contact, SummaryList, "[data-qa=ucas_application_alert_contact]"
        section :send_application_alerts, SummaryList, "[data-qa=ucas_send_application_alerts]"
      end
    end
  end
end
