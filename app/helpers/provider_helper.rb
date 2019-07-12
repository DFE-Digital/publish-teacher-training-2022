module ProviderHelper
  def add_course_url(email, provider, is_current_cycle:)
    cycle_key = is_current_cycle ? 'current_cycle' : 'next_cycle'

    if provider.accredited_body?
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_accredited_bodies, email, provider)
    else
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_unaccredited_bodies, email, provider)
    end
  end

  def add_course_link(email, provider, is_current_cycle:)
    link_to "Add a new course", add_course_url(email, provider, is_current_cycle: is_current_cycle), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank"
  end

  def google_form_url_for(settings, email, provider)
    settings.url + "&" +
      { settings.email_entry => email, settings.provider_code_entry => provider.provider_code }.to_query
  end
end
