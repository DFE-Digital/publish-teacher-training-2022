module ProviderHelper
  def add_course_url(email, provider)
    if provider.accredited_body?
      google_form_url_for(Settings.google_forms.new_course_for_accredited_bodies, email, provider)
    else
      google_form_url_for(Settings.google_forms.new_course_for_unaccredited_bodies, email, provider)
    end
  end

  def add_course_link(email, provider)
    link_to "Add a new course", add_course_url(email, provider), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank"
  end

  def add_location_url(email, provider)
    google_form_url_for(Settings.google_forms.add_location, email, provider)
  end

  def add_location_link(email, provider)
    link_to "Add a location", add_location_url(email, provider), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank"
  end

  def google_form_url_for(settings, email, provider)
    settings.url + "&" +
      { settings.email_entry => email, settings.provider_code_entry => provider.provider_code }.to_query
  end
end
