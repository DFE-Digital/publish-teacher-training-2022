module ProviderHelper
  def add_course_url(email, provider, is_current_cycle:)
    cycle_key = is_current_cycle ? "current_cycle" : "next_cycle"

    if provider.accredited_body?
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_accredited_bodies, email, provider)
    else
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_unaccredited_bodies, email, provider)
    end
  end

  def create_course_link(provider, **opts)
    govuk_link_to("Add a new course", new_provider_recruitment_cycle_course_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year), class: "govuk-button govuk-!-margin-bottom-2", **opts)
  end

  def add_course_link(email, provider, is_current_cycle:, **opts)
    link_to "Add a new course", add_course_url(email, provider, is_current_cycle: is_current_cycle), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank", **opts
  end

  def google_form_url_for(settings, email, provider)
    settings.url + "&" +
      { settings.email_entry => email, settings.provider_code_entry => provider.provider_code }.to_query
  end
end
