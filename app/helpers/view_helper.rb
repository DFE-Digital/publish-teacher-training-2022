module ViewHelper
  def manage_ui_link_to(body, url, html_options = { class: 'govuk-link' })
    link_to body, "#{Settings.manage_ui.base_url}#{url}", html_options
  end

  def manage_ui_link_to_back(url)
    manage_ui_link_to('Back', url, class: "govuk-back-link")
  end
end
