class ApplicationDecorator < Draper::Decorator
  def status_tag
    tag = h.content_tag(:div, status_tag_content.html_safe, class: "govuk-tag phase-tag--small #{status_tag_css_class}")
    tag += unpublished_status_hint if object.has_unpublished_changes?
    tag.html_safe
  end

private

  def status_tag_content
    case object.content_status
    when 'published'
      'Published'
    when 'empty'
      'Empty'
    when 'draft'
      'Draft'
    when 'published_with_unpublished_changes'
      'Published&nbsp;*'
    when 'rolled_over'
      'Rolled over'
    end
  end

  def status_tag_css_class
    case object.content_status
    when 'published'
      'phase-tag--published'
    when 'empty'
      'phase-tag--no-content'
    when 'draft'
      'phase-tag--draft'
    when 'published_with_unpublished_changes'
      'phase-tag--published'
    when 'rolled_over'
      'phase-tag--no-content'
    end
  end

  def unpublished_status_hint
    h.content_tag(:div, '*&nbsp;Unpublished&nbsp;changes'.html_safe, class: 'govuk-body govuk-body-s govuk-!-margin-bottom-0 govuk-!-margin-top-1')
  end
end
