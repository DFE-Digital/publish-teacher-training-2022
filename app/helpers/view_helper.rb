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

  def enrichment_error_url(provider_code:, course:, field:)
    base = "/organisations/#{provider_code}/courses/#{course.course_code}"

    {
      'about_course' => base + '/about#about_course_wrapper',
      'how_school_placements_work' => base + '/about#how_school_placements_work_wrapper',
      'fee_uk_eu' => base + '/fees#fee_uk_eu_wrapper',
      'course_length' => base + (course.has_fees? ? '/fees' : '/salary') + '#course_length_wrapper',
      'salary_details' => base + '/salary#salary_details_wrapper',
      'qualifications' => base + '/requirements#required_qualifications_wrapper'
    }[field]
  end

  def header_environment_class
    "app-header__container--#{Settings.environment.selector_name}"
  end

  def beta_tag_environment_class
    "app-tag--#{Settings.environment.selector_name}"
  end

  def beta_banner_environment_label
    Settings.environment.label
  end

  # Ad-hoc, informally specified, and bug-ridden Ruby implementation of half
  # of https://github.com/JedWatson/classnames.
  #
  # Example usage:
  #   <input class="<%= cns("govuk-input", "govuk-input--width-10": is_small) %>">
  def classnames(*args)
    args.reduce('') do |str, arg|
      classes =
        if arg.is_a? Hash
          arg.reduce([]) { |cs, (classname, condition)| cs + [condition ? classname : nil] }
        elsif arg.is_a? String
          [arg]
        else
          []
        end
      ([str] + classes).reject(&:blank?).join(' ')
    end
  end

  alias_method :cns, :classnames
end
