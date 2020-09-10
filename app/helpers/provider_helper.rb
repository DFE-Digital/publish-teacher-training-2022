module ProviderHelper
  def add_course_url(email, provider)
    cycle_key = is_current_cycle(provider.recruitment_cycle_year) ? "current_cycle" : "next_cycle"

    if provider.accredited_body?
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_accredited_bodies, email, provider)
    else
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_unaccredited_bodies, email, provider)
    end
  end

private

  def google_form_url_for(settings, email, provider)
    settings.url + "&" +
      { settings.email_entry => email, settings.provider_code_entry => provider.provider_code }.to_query
  end

  def is_current_cycle(cycle_year)
    Settings.current_cycle == cycle_year.to_i
  end
end
