module ProviderHelper
  def add_course_link(provider)
    google_form_url = if provider.accredited_body?
                        Settings.google_forms.new_course_for_accredited_bodies_url
                      else
                        Settings.google_forms.new_course_for_unaccredited_bodies_url
                      end

    link_to "Add a new course", google_form_url, class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank"
  end
end
