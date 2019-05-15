module ViewHelper
  def govuk_link_to(body, url = body, html_options = { class: 'govuk-link' })
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

  def bat_contact_email_address
    Settings.service_support.contact_email_address
  end

  def bat_contact_email_address_with_wrap
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/wbr
    # The <wbr> element will not be copied when copying and pasting the email address
    bat_contact_email_address.gsub('@', '<wbr>@').html_safe
  end

  def bat_contact_mail_to(name = nil, subject: nil, link_class: "govuk-link")
    mail_to bat_contact_email_address, name || bat_contact_email_address, subject: subject, class: link_class
  end

  def manage_ui_enrichment_error_url(provider_code:, course:, field:)
    base = manage_ui_course_page_url(provider_code: provider_code, course_code: course.course_code)

    {
      'about_course' => base + '/about#AboutCourse-wrapper',
      'how_school_placements_work' => base + '/about#HowSchoolPlacementsWork-wrapper',
      'fee_uk_eu' => base + '/fees-and-length#FeeUkEu-wrapper',
      'course_length' => base + (course.has_fees? ? '/fees-and-length' : '/salary') + '#CourseLength-wrapper',
      'salary_details' => base + '/salary#SalaryDetails-wrapper',
      'qualifications' => base + '/requirements#Qualifications-wrapper'
    }[field]
  end
end
