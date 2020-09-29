class UcasContactView
  CONTACT_TYPES = %i[admin fraud finance web_link utt].freeze
  attr_reader :provider

  def initialize(provider:)
    @provider = provider
  end

  def contact(contact_type)
    provider.contacts.find { |contact| contact.type.to_sym == contact_type.to_sym }
  end

  def contact_types
    UcasContactView::CONTACT_TYPES
  end

  delegate :provider_code,
           :gt12_contact,
           :send_application_alerts,
           :application_alert_contact,
           to: :provider
end
