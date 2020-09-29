module PageObjects
  module Page
    module Organisations
      class UcasContacts < PageObjects::Base
        class ContactDetail < SitePrism::Section
          element :details, ".govuk-summary-list__value"
          element :change_link, ".govuk-summary-list__actions a"
        end

        set_url "/organisations/{provider_code}/ucas-contacts"

        element :flash, ".govuk-success-summary"
        sections :contacts, ContactDetail, ".ucas-contact-list__row"
        section :admin_contact, ContactDetail, ".ucas-contact-list__row__admin"
        section :utt_contact, ContactDetail, ".ucas-contact-list__row__utt"
        section :web_link_contact, ContactDetail, ".ucas-contact-list__row__web_link"
        section :finance_contact, ContactDetail, ".ucas-contact-list__row__finance"
        section :fraud_contact, ContactDetail, ".ucas-contact-list__row__fraud"

        section :gt12_contact, ContactDetail, "[data-qa='provider__gt12_contact']"

        element :application_alert_contact, "[data-qa='provider__application_alert_contact']"
        element :send_application_alerts, "[data-qa='provider__send_application_alerts']"
        element :send_application_alerts_link, "a[data-qa=send_application_alerts__change]", text: "Change"
        element :application_alert_contact_link, "a[data-qa=application_alert_contact__change]", text: "Change"
      end
    end
  end
end
