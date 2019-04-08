module ViewHelper
  def govuk_link_to(body, url, html_options = { class: 'govuk-link' })
    link_to body, url, html_options
  end

  def govuk_back_link_to(url)
    govuk_link_to('Back', url, class: "govuk-back-link")
  end

  def manage_ui_url(relative_path)
    URI.join(Settings.manage_ui.base_url, relative_path).to_s
  end

  def manage_ui_course_page_url(provider_code:, course_code:)
    manage_ui_url("/organisation/#{provider_code}/course/self/#{course_code}")
  end

  def search_ui_url(relative_path)
    URI.join(Settings.search_ui.base_url, relative_path).to_s
  end

  def search_ui_course_page_url(provider_code:, course_code:)
    search_ui_url("/course/#{provider_code}/#{course_code}")
  end

  def bat_contact_mail_to(name = nil, subject: nil, link_class: "govuk-link")
    contact_email_address = Settings.service_support.contact_email_address
    mail_to contact_email_address, name || contact_email_address, subject: subject, class: link_class
  end
end
