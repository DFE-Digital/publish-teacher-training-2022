module ProviderHelper
  def add_course_url(email, provider)
    if provider.accredited_body?
      Settings.google_forms.new_course_for_accredited_bodies_url + "?" +
        {usp: 'pp_url', "entry.957076544" => email, "entry.1735563938" => provider.provider_code}.to_query
    else
      Settings.google_forms.new_course_for_unaccredited_bodies_url + "?" +
        {usp: 'pp_url', "entry.1033530353" => email, "entry.158771972" => provider.provider_code}.to_query
    end
  end

  def add_course_link(email, provider)
    link_to "Add a new course", add_course_url(email, provider), class: "govuk-button govuk-!-margin-bottom-2", rel: "noopener noreferrer", target: "_blank"
  end

  def add_location_url(email, provider)
    Settings.google_forms.add_location_url + "?" + {usp: 'pp_url', "entry.1913622198" => email, "entry.1075663095" => provider.provider_code}.to_query
  end

  def add_location_link(email, provider)
    link_to "Add a location", add_location_url(email, provider), rel: "noopener noreferrer", class: "govuk-button govuk-!-margin-bottom-2", target: :blank
  end
end
