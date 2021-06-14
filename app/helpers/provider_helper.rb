module ProviderHelper
  def add_course_url(email, provider)
    cycle_key = is_current_cycle(provider.recruitment_cycle_year) ? "current_cycle" : "next_cycle"

    if provider.accredited_body?
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_accredited_bodies, email, provider)
    else
      google_form_url_for(Settings.google_forms[cycle_key].new_course_for_unaccredited_bodies, email, provider)
    end
  end

  def visa_sponsorship_status(provider)
    if provider.can_sponsor_student_visa.nil? || provider.can_sponsor_skilled_worker_visa.nil?
      govuk_inset_text(classes: %w[app-inset-text app-inset-text--important]) do
        raw("<p class=\"govuk-heading-s app-inset-text__title\">Can you sponsor visas?</p>") +
          govuk_link_to(
            "Select if you can sponsor visas",
            provider_recruitment_cycle_visas_edit_path(
              provider.provider_code,
              provider.recruitment_cycle_year,
            ),
          )
      end
    elsif provider.can_sponsor_student_visa && provider.can_sponsor_skilled_worker_visa
      "You can sponsor Student and Skilled Worker visas"
    elsif provider.can_sponsor_student_visa && !provider.can_sponsor_skilled_worker_visa
      "You can sponsor Student visas"
    elsif !provider.can_sponsor_student_visa && provider.can_sponsor_skilled_worker_visa
      "You can sponsor Skilled Worker visas"
    else
      "You cannot sponsor visas"
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
